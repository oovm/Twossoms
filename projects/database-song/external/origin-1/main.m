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
(*seq=Partition[l,{UpTo[3]}];*)
	seq = Quiet@Check[
		FromCharacterCode[l, "UTF-8"],
		FromCharacterCode[Flatten@SequenceSplit[l, {240, a_, b_, c_} :> {9633}], "UTF-8"]
	];
	StringJoin@seq
];
read[local_] := GeneralUtilities`Scope[
	byte = Normal@ReadByteArray@FileNameJoin[{$here, local}];
	str = checkUTF /@ SequenceSplit[toASCII /@ byte, {s_String} :> StringJoin@s];
	Return[str];
	ImportString[StringJoin@str, "RawJSON"]
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
	Export[
		FileNameJoin[{DirectoryName@$here, FileBaseName@$here <> ".mx"}],
		Dataset@data, "CSV",
		CharacterEncoding -> "UTF8"
	]
];
$finish = Now;



