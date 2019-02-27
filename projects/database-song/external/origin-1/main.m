(* ::Package:: *)

(* ::Section:: *)
(*Settings*)


$source = "https://github.com/chinese-poetry/chinese-poetry";
$here = NotebookDirectory[];
$now = Now;


(* ::Section:: *)
(*Data*)


(* ::Subsection:: *)
(*Tasks*)


$tasks = GeneralUtilities`Scope[
	url = StringTemplate["https://github.com/chinese-poetry/chinese-poetry/raw/master/ci/ci.song.`i`.json"];
	Table[{"download-" <> IntegerString[i + 1, 10, 2] <> ".mx", url[<|"i" -> 1000i|>]}, {i, 0, 21}]
];


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


toASCII[s_String] := s;
toASCII[i_Integer] := If[i < 127, FromCharacterCode@i, i];
checkUTF[s_String] := s;
checkUTF[l_List] := GeneralUtilities`Scope[
	seq = Quiet@Check[
		FromCharacterCode[l, "UTF-8"],
		FromCharacterCode[Flatten@SequenceSplit[l, {240, a_, b_, c_} :> {9633}], "UTF-8"]
	];
	StringJoin@seq
];
read[local_] := GeneralUtilities`Scope[
	Quiet@Check[
		Import[FileNameJoin[{$here, local}], "RawJSON"],
		byte = Normal@ReadByteArray@FileNameJoin[{$here, local}];
		str = Flatten@SequenceSplit[byte, {240, a_, b_, c_} :> {226, 150, 161}];
		Export["tmp.mx", FromCharacterCode[str, "UTF-8"], "Text"];
		Import["tmp.mx", "RawJSON"]
	]
];


Block[
	{format, data},
	format = <|
		"Title" -> #rhythmic,
		"Author" -> #author,
		"Ci" -> StringRiffle[ #paragraphs, "|"]
	|>&;
	data = Apply[Join, read@*First /@ $tasks];
	data = Query[All, format]@Apply[Join, read@*First /@ $tasks];
	(*data=Query[All,If[#Ci=="",Nothing,#]&]@SortBy[data,#Author&];*)
	Export[
		FileNameJoin[{DirectoryName@$here, FileBaseName@$here <> ".mx"}],
		Dataset@data, "CSV",
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
		If[Import@cache == this, Return[]]
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
