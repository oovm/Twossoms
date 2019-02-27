(* ::Package:: *)

(* ::Section:: *)
(*Setting*)


$now = Now;
$here = NotebookDirectory[];
$release = FileNameJoin[{DirectoryName@$here, "release"}];


(* ::Section:: *)
(*Main*)


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
(*Export Base Data *)


(* ::Section:: *)
(*Import*)


data1 := data1 = Import[FileNameJoin[{$here, "origin-1.mx"}], "CSV"];
data2 := data2 = Import[FileNameJoin[{$here, "origin-2.mx"}], "CSV"];


(* ::Section:: *)
(*Data*)


data = Join[data1, data2];
data = SortBy[Append[#, ""]& /@ DeleteDuplicatesBy[data, First], Rest];


(* ::Section:: *)
(*Export*)


Export[
	FileNameJoin[{$here, "database-base.csv"}],
	Select[data, StringLength@First[#] > 3&],
	"TableHeadings" -> {"Idiom", "Pinyin", "Explanation", "Synonym"},
	CharacterEncoding -> "UTF8"
];


(* ::Section:: *)
(*Import Fix*)


$replace := $replace = GeneralUtilities`Scope[
	import = Import[
		FileNameJoin[{$here, "database-replace.csv"}],
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


$remove := GeneralUtilities`Scope[
	import = Import@FileNameJoin[{$here, "database-remove.csv"}];
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


(* ::Section:: *)
(*Additional*)


Export[
	"database-3char.csv",
	GroupBy[data[[All, ;; 3]], StringLength@*First][3],
	"TableHeadings" -> {"Idiom", "Pinyin", "Explanation"},
	CharacterEncoding -> "UTF8"
];


(* ::Section:: *)
(*Report*)


(* ::Section:: *)
(*Record*)
