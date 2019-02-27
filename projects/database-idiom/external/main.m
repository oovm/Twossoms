(* ::Package:: *)

(* ::Chapter:: *)
(*Setting*)


$now = Now;
$here = NotebookDirectory[];
$release = FileNameJoin[{DirectoryName@$here, "release"}];
$ = Association[];


(* ::Chapter:: *)
(*Main*)


(* ::Subchapter:: *)
(*Functions*)


norm = RemoveDiacritics[#, Language -> "English"]&;
addLetter = <|
	"Idiom" -> #Idiom,
	"Pinyin" -> #Pinyin,
	"Letter" -> norm[#Pinyin],
	"Explanation" -> #Explanation,
	"Synonym" -> #Synonym
|>&;


(* ::Subchapter:: *)
(*Export Base Data *)


(* ::Subsection:: *)
(*Import*)


data1 := data1 = Import[FileNameJoin[{$here, "origin-1.mx"}], "CSV"];
data2 := data2 = Import[FileNameJoin[{$here, "origin-2.mx"}], "CSV"];


(* ::Subsection:: *)
(*Data*)


data = Join[data1, data2];
data = SortBy[DeleteDuplicatesBy[data, First], Rest];


(* ::Subsection:: *)
(*Export*)


Export[
	FileNameJoin[{$here, "database-base.csv"}],
	Select[data, StringLength@First[#] > 3&],
	"TableHeadings" -> {"Idiom", "Pinyin", "Explanation", "Synonym"},
	CharacterEncoding -> "UTF8"
];


Export[
	"database-3char.csv",
	GroupBy[data[[All, ;; 3]], StringLength@*First][3],
	"TableHeadings" -> {"Idiom", "Pinyin", "Explanation"},
	CharacterEncoding -> "UTF8"
];



(* ::Subchapter:: *)
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


(* ::Subchapter:: *)
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


With[
	{name = "idioms.csv"},
	Export[
		FileNameJoin[{$release, name}],
		Select[data, StringLength@First[#] > 3&],
		"TableHeadings" -> {"Idiom", "Pinyin", "Explanation", "Synonym"},
		CharacterEncoding -> "UTF8"
	];
	$[name] = IntegerString[FileHash[FileNameJoin[{$release, name}], "MD5"], 16]
]


(* ::Chapter:: *)
(*Report*)


(* ::Chapter:: *)
(*Record*)


Block[
	{record, old, updater, new},
	record = Import[FileNameJoin[{$release, "record.json"}], "RawJSON"];
	old = record["files"];
	updater = If[
		$[#name] != #md5,
		<|"name" -> #name, "version" -> #version + 1, "md5" -> $[#name], "update" -> DateString[$now]|>,
		#
	]&;
	new = SortBy[updater /@ old, #name&];
	If[
		Tr[#version& /@ new] > Tr[#version& /@ old],
		Export[
			FileNameJoin[{$release, "record.json"}],
			<|
				"name" -> record["name"],
				"version" -> record["version"] + {0, 0, 1},
				"files" -> new
			|>
		]
	]
];
