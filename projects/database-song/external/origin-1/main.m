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


read[local_] := Import[FileNameJoin[{$here, local}], "RawJson"];
Block[
	{format, data},
	format = <|
		"Title" -> #rhythmic,
		"Author" -> #author,
		"Ci" -> StringRiffle[ #paragraphs, "|"]
	|>&;
	data = Apply[Join, read@*First /@ $tasks];
	data = Query[All, format]@Apply[Join, read@*First /@ $tasks];
	Export[
		FileNameJoin[{DirectoryName@$here, FileBaseName@$here <> ".mx"}],
		Dataset@data, "CSV",
		CharacterEncoding -> "UTF8"
	]
];
$finish = Now;
