(* ::Package:: *)

(* ::Section:: *)
(*Settings*)


$source = "https://github.com/by-syk/chinese-idiom-db";
$here = NotebookDirectory[];
$now = Now;


(* ::Section:: *)
(*Data*)


(* ::Subsection:: *)
(*Tasks*)


$tasks = {
	{
		"download.mx",
		"https://github.com/by-syk/chinese-idiom-db/raw/master/chinese-idioms-12976.txt"
	}
};


(* ::Subsection:: *)
(*Download*)


check[local_, remote_] := GeneralUtilities`Scope[
	file = FileNameJoin[{$here, local}];
	If[
		!FileExistsQ@file,
		URLDownloadSubmit[remote, file],
		Return@Nothing
	]
];
TaskWait[check @@@ $tasks];
$download = Now;


(* ::Subsection:: *)
(*Export*)


read[local_] := Import[FileNameJoin[{$here, local}], "CSV"];
Block[
	{data},
	data = Apply[Join, read@*First /@ $tasks][[All, {2, 3, 4}]];
	data = MapAt[StringRiffle@*StringSplit, data, {All, 2}];
	data = SortBy[Append[#, ""]& /@ DeleteDuplicatesBy[data, First], Rest];
	Export[
		FileNameJoin[{DirectoryName@$here, "origin-1.mx"}],
		data, "CSV",
		"TableHeadings" -> {"Idiom", "Pinyin", "Explanation"},
		CharacterEncoding -> "UTF8"
	]
];
$finish=Now;
