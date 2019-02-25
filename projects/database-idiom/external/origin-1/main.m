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


data = MapAt[StringRiffle@*StringSplit, Join[data1, data2], {All, 2}];
data = SortBy[Append[#, ""]& /@ DeleteDuplicatesBy[data, First], Rest];


Export[
	"database-base.csv",
	Select[data, StringLength@First[#] > 3&],
	"TableHeadings" -> {"Idiom", "Pinyin", "Explanation", "Synonym"},
	CharacterEncoding -> "UTF8"
];
