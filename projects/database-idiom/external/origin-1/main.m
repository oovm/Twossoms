(* ::Package:: *)

(* ::Section:: *)
(*Setting*)


$reference = "https://github.com/by-syk/chinese-idiom-db";
$here = NotebookDirectory[];
$now = Now;


(* ::Section:: *)
(*Data*)
$tasks = {
	{
		"download.mx",
		"https://github.com/by-syk/chinese-idiom-db/raw/master/chinese-idioms-12976.txt"
	}
};
check[local_, remote_] := GeneralUtilities`Scope[
	file = FileNameJoin[{$here, local}];
	If[
		!FileExistsQ@file,
		URLDownloadSubmit[remote, file],
		Return@Nothing
	]
]
TaskWait[check @@@ $tasks];
$download = Now;



	tmp = Import["Source_1.mx", "CSV"];
	Echo[Length@tmp, "Records:"];
	tmp[[All, {2, 3, 4}]]



data = MapAt[StringRiffle@*StringSplit, Join[data1, data2], {All, 2}];
data = SortBy[Append[#, ""]& /@ DeleteDuplicatesBy[data, First], Rest];


Export[
	"database-base.csv",
	Select[data, StringLength@First[#] > 3&],
	"TableHeadings" -> {"Idiom", "Pinyin", "Explanation", "Synonym"},
	CharacterEncoding -> "UTF8"
];
