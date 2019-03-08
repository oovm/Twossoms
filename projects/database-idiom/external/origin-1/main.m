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
		FileNameJoin[{DirectoryName@$here, FileBaseName@$here <> ".mx"}],
		data, "CSV",
		"TableHeadings" -> {"Idiom", "Pinyin", "Explanation", "Synonym"},
		CharacterEncoding -> "UTF8"
	]
];
$finish = Now;


(* ::Section:: *)
(*Report*)


hash[local_] := IntegerString[FileHash[FileNameJoin[{$here, local}]], 16];
Block[
	{this, cache, report},
	this = Tr[FileHash[FileNameJoin[{$here, First@#}]]& /@ $tasks];
	cache = FileNameJoin[{$here, "chche.mx"}];
	If[
		!FileExistsQ@cache,
		Export[cache, this],
		If[Import@cache == this, Return[Null]]
	];
	report = {
		{"## Idioms Database Log"},
		
		{"- Date: ", $now},
		
		{"- Source: ", $source},
		
		{"- Downloading: ", $download - $now},
		
		{"- Processing: ", $finish - $download},
		
		{},
		
		{"|File|Hash|"},
		{"|----|----|"},
		Apply[Sequence, {"|", #1, "|", hash@#1, "|"}& @@@ $tasks]
		
	};
	Export[FileNameJoin[{$here, "Readme.md"}], StringRiffle[report, "\n", ""], "Text"]
];
