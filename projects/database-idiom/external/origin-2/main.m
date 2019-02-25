(* ::Package:: *)

(* ::Section:: *)
(*Settings*)


$source = "https://github.com/pwxcoo/chinese-xinhua";
$here = NotebookDirectory[];
$now = Now;


(* ::Section:: *)
(*Data*)


(* ::Subsection:: *)
(*Tasks*)


$tasks = {
	{
		"download.mx",
		"https://github.com/pwxcoo/chinese-xinhua/raw/master/data/idiom.json"
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


read[local_] := Import[FileNameJoin[{$here, local}], "RawJSON"];
Block[
	{data},
	data = Apply[Join, read@*First /@ $tasks];
	data = Query[All, {#word, #pinyin, #explanation}&]@data;
	data = SortBy[Append[#, ""]& /@ DeleteDuplicatesBy[data, First], Rest];
	Export[
		FileNameJoin[{DirectoryName@$here, FileBaseName@$here <> ".mx"}],
		data, "CSV",
		"TableHeadings" -> {"Idiom", "Pinyin", "Explanation"},
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
