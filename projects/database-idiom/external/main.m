(* ::Package:: *)

(* ::Section:: *)
(*Setting*)


SetDirectory@NotebookDirectory[];


(* ::Section:: *)
(*Data*)


data1 := data1 = GeneralUtilities`Scope[
	Print@Hyperlink["https://github.com/by-syk/chinese-idiom-db"];
	r := URLDownload[
		"https://github.com/by-syk/chinese-idiom-db/raw/master/chinese-idioms-12976.txt",
		"Source_1.mx"
	];
	If[!FileExistsQ@"Source_1.mx", r];
	tmp = Import["Source_1.mx", "CSV"];
	Echo[Length@tmp, "Records:"];
	tmp[[All, {2, 3, 4}]]
];


data2 := data2 = GeneralUtilities`Scope[
	Print@Hyperlink["https://github.com/pwxcoo/chinese-xinhua"];
	r := URLDownload[
		"https://github.com/pwxcoo/chinese-xinhua/raw/master/data/idiom.json",
		"Source_2.mx"
	];
	If[!FileExistsQ@"Source_2.mx", r];
	tmp = Import["Source_2.mx", "RawJSON"];
	Echo[Length@tmp, "Records:"];
	Values /@ tmp[[All, {"word", "pinyin", "explanation"}]]
];


data3 := data3 = GeneralUtilities`Scope[
	Print@Hyperlink["https://github.com/pwxcoo/chinese-xinhua"];
	r := URLDownload[
		"https://raw.githubusercontent.com/pwxcoo/chinese-xinhua/master/data/ci.json",
		"Source_3.mx"
	];
	If[!FileExistsQ@"Source_3.mx", r];
	tmp = Import["Source_3.mx", "RawJSON"];
	Echo[Length@tmp, "Records:"];
	GroupBy[tmp, StringLength@#ci&][4]
(*Values /@ tmp[[All, {"word", "pinyin", "explanation"}]]*)
];


data = MapAt[StringRiffle@*StringSplit, Join[data1, data2], {All, 2}];
data = SortBy[Append[#, ""]& /@ DeleteDuplicatesBy[data, First], Rest];


(* ::Section:: *)
(*Export Base*)


(* ::Subsection:: *)
(*Export*)


Export[
	"database-base.csv",
	Select[data, StringLength@First[#] > 3&],
	"TableHeadings" -> {"Idiom", "Pinyin", "Explanation", "Synonym"},
	CharacterEncoding -> "UTF8"
];


(* ::Subsection:: *)
(*Export Accelerate*)


(* ::Input:: *)
(*string = ExportString[*)
(*	SortBy[data, Rest], "CSV",*)
(*	"TableHeadings" -> {"Idiom", "Pinyin", "Explanation"},*)
(*	CharacterEncoding -> "UTF8"*)
(*];*)
(*Export["database.csv", string, "Table", CharacterEncoding -> "UTF8"]*)


(* ::Section:: *)
(*Export Other*)


Export[
	"database-3char.csv",
	GroupBy[data[[All, ;; 3]], StringLength@*First][3],
	"TableHeadings" -> {"Idiom", "Pinyin", "Explanation"},
	CharacterEncoding -> "UTF8"
];


(* ::Input:: *)
(*formatter=<|"Word"->#ci,"Explanation"->#explanation|>&*)
(*Query[All,formatter][Dataset@data3]*)


(* ::Section:: *)
(*Functions*)


norm = RemoveDiacritics[#, Language -> "English"]&;
addLetter = <|
	"Idiom" -> #Idiom,
	"Pinyin" -> #Pinyin,
	"Letter" -> norm[#Pinyin],
	"Explanation" -> #Explanation,
	"Synonym" -> #Synonym
|>&;


(* ::Section:: *)
(*Import Fix*)


$replace = GeneralUtilities`Scope[
	import = Import[
		"database-replace.csv",
		{"CSV", "Data"},
		"HeaderLines" -> 1,
		"IgnoreEmptyLines" -> True
	];
	export = Sort@DeleteDuplicates@import;
	Export[
		"database-replace.csv",
		export, "CSV",
		"TableHeadings" -> {"Idiom", "Pinyin", "Explanation", "Synonym"},
		"FillRows" -> False
	];
	Return[export]
];


$remove = GeneralUtilities`Scope[
	import = Import["database-remove.csv"];
	add = StringSplit[Last@#, "|"]& /@ $replace;
	export = Sort@DeleteDuplicates@Flatten@Join[First /@ $replace, import, add];
	Export[
		"database-remove.csv",
		Partition[DeleteCases[DeleteDuplicates@export, ""], UpTo[10]],
		"TextDelimiters" -> ""
	];
	Return[export]
];


(* ::Section:: *)
(*Apply Fix*)


$base = Import["database-base.csv", {"CSV", "Dataset"}, "HeaderLines" -> 1];
data = Query[DeleteCases[_?(MemberQ[$remove, #Idiom]&)]]@$base;
import = Import["database-replace.csv", {"CSV", "Dataset"}, "HeaderLines" -> 1];
export = Dataset@SortBy[Join[data, Normal@import], #Pinyin&];
Export[
	FileNameJoin[{ParentDirectory[NotebookDirectory[]], "external", "database.csv"}],
	Query[All, addLetter]@export,
	CharacterEncoding -> "UTF8"
]
