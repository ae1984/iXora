/* VALM_ps.p
 * MODULE
        Валютный монитор        
 * DESCRIPTION
        Валютный монитор
 RUN
        Процесс платежной системы. Запускать ТОЛЬКО под Superman! 
 * CALLER
        стандартные для процессов
 * SCRIPT
        стандартные для процессов
 * INHERIT
        стандартные для процессов
 * MENU
        5.1
 * AUTHOR
        27.04.2004 tsoy
 * CHANGES
       16.05.2004 tsoy Добавил навигацию
       17.05.2004 tsoy Разделение данных
       30.06.2004 tsoy Добавил дату валютирования
       02.07.2004 tsoy перекомпиляция
       21.09.2004 kanat поменял пути с локальной машины на ntmain
       04.10.2004 tsoy убрал один lgps
       22.06.2005 Добавил заполенеие vmtmptbl
       04.08.2006 Добавил 942

*/

{global.i}

{lgps.i }

define stream m-out.
define stream m-outdt.

output stream m-out   to valmon.html.
output stream m-outdt to valmonhd.html.

def var v-unidir as char.
def var v-result as char.
def var v-clsday as date.

put stream m-out unformatted
    "<HTML PUBLIC ""-//W3C//DTD HTML 4.0 Transitional//EN""> "  skip
    "<HEAD>                     "                               skip
    "<STYLE type=text/css>BODY \{      "                        skip
    "    COLOR: #202020; FONT-FAMILY: verdana; FONT-SIZE: 8pt " skip
    "\}"                                                        skip
    "TD \{"                                                     skip
    "    COLOR: #202020; FONT-FAMILY: verdana; FONT-SIZE: 8pt"  skip
    "\}"                                                        skip
    "TH \{"                                                     skip
    "    COLOR: #202020; FONT-FAMILY: verdana; FONT-SIZE: 8pt"  skip
    "\}"                                                        skip.

put stream m-outdt unformatted
    "<HTML PUBLIC ""-//W3C//DTD HTML 4.0 Transitional//EN""> "  skip
    "<HEAD>                     "                               skip
    "<STYLE type=text/css>BODY \{      "                        skip
    "    COLOR: #202020; FONT-FAMILY: verdana; FONT-SIZE: 8pt " skip
    "\}"                                                        skip
    "INPUT \{" skip
    "    BACKGROUND-COLOR: #eeeeee; BORDER-BOTTOM: #9899c0 1px solid; BORDER-LEFT: #9899c0 1px solid; BORDER-RIGHT: #9899c0 1px solid; BORDER-TOP: #9899c0 1px solid; COLOR: #202020; FONT-FAMILY: verdana; FONT-SIZE: 8pt" skip
    "\}"                                                        skip
    "TD \{"                                                     skip
    "    COLOR: #202020; FONT-FAMILY: verdana; FONT-SIZE: 8pt"  skip
    "\}"                                                        skip
    "TH \{"                                                     skip
    "    COLOR: #202020; FONT-FAMILY: verdana; FONT-SIZE: 8pt"  skip
    "\}"                  
    "INPUT.buttons \{                                                   " skip
    "    BACKGROUND-COLOR: #ffffff; FONT-WEIGHT: bold; WIDTH: 150px     " skip
    "\}                                                                 " skip.

put stream m-outdt unformatted
    "H1 \{                                                                                                                                    " skip
    "    BACKGROUND-COLOR: #ffc972; COLOR: #202020; FONT-SIZE: 8pt; FONT-WEIGHT: bold; MARGIN: 0px 0px 10px; PADDING-BOTTOM: 1px; PADDING-LEFT: 3px; PADDING-RIGHT: 3px; PADDING-TOP: 3px; TEXT-TRANSFORM: uppercase" skip
    "\}                                                                                                                                                                                                              " skip
    "H2 \{                                                                                                                                                                                                           " skip
    "    BACKGROUND-COLOR: #ffc972; COLOR: #202020; FONT-SIZE: 8pt; FONT-WEIGHT: bold; MARGIN: 0px 0px 10px; PADDING-BOTTOM: 1px; PADDING-LEFT: 3px; PADDING-RIGHT: 3px; PADDING-TOP: 3px; TEXT-TRANSFORM: uppercase" skip
    "\}                                                                                                                                                                                                              " skip
    "H3 \{                                                                                                                                                                                                           " skip
    "    FONT-SIZE: 8pt; FONT-WEIGHT: bold; MARGIN: 0px; PADDING-BOTTOM: 3px; PADDING-LEFT: 0px; PADDING-RIGHT: 3px; PADDING-TOP: 3px                                                                               " skip.

put stream m-outdt unformatted
    "\}                                                                                                                                                                                                              " skip
    "HR \{                                                                                                                                                                                                           " skip
    "    COLOR: #95b2d6; HEIGHT: 1px; WIDTH: 100%                                                                                                                                                                   " skip
    "\}                                                                                                                                                                                                              " skip
    "A \{                                                                                                                                                                                                            " skip
    "    COLOR: #000099; TEXT-DECORATION: none                                                                                                                                                                      " skip
    "\}                                                                                                                                                                                                              " skip
    "A:hover \{                                                                                                                                                                                                      " skip
    "    TEXT-DECORATION: underline                                                                                                                                                                                 " skip
    "\}                                                                                                                                                                                                              " skip
    "A.tpbtn \{                                                                                                                                                                                                      " skip
    "    COLOR: #ffffff                                                                                                                                                                                             " skip
    "\}                                                                                                                                                                                                              " skip.

put stream m-outdt unformatted
    "A.tpbtn:visited \{                                                                                                                                                                                              " skip
    "    COLOR: #ffffff                                                                                                                                                                                             " skip
    "\}                                                                                                                                                                                                              " skip
    "A.tpbtn:active \{                                                                                                                                                                                               " skip
    "    COLOR: #ffffff                                                                                                                                                                                             " skip
    "\}                                                                                                                                                                                                              " skip
    "A.tpbtn:hover \{                                                                                                                                                                                                " skip
    "    COLOR: #3a5579                                                                                                                                                                                             " skip
    "\}                                                                                                                                                                                                              " skip
    ".yel \{                                                                                                                                                                                                         " skip
    "    backgorund-color: #FF0000                                                                                                                                                                                  " skip
    "\}                                                                                                                                                                                                              " skip
    ".thead \{                                                                                                                                                                                                       " skip
    "    COLOR: #949494                                                                                                                                                                                             " skip
    "\}                                                                                                                                                                                                              " skip
    "A.men1 \{                                                                                                                                                                                                       " skip.

put stream m-outdt unformatted
    "    COLOR: #020202; PADDING-BOTTOM: 3px; PADDING-LEFT: 2px; PADDING-RIGHT: 3px; PADDING-TOP: 3px; TEXT-DECORATION: none; WIDTH: 100%                                                                           " skip
    "\}                                                                                                                                                                                                              " skip
    "A.men1:visited \{                                                                                                                                                                                               " skip
    "    COLOR: #020202; PADDING-BOTTOM: 3px; PADDING-LEFT: 2px; PADDING-RIGHT: 3px; PADDING-TOP: 3px; TEXT-DECORATION: none; WIDTH: 100%                                                                           " skip
    "\}                                                                                                                                                                                                              " skip
    "A.men1:active \{                                                                                                                                                                                                " skip
    "    COLOR: #020202; PADDING-BOTTOM: 3px; PADDING-LEFT: 2px; PADDING-RIGHT: 3px; PADDING-TOP: 3px; TEXT-DECORATION: none; WIDTH: 100%                                                                           " skip
    "\}                                                                                                                                                                                                              " skip.
put stream m-outdt unformatted
    "A.men1:hover \{                                                                                                                                                                                                 " skip
    "    COLOR: #020202; PADDING-BOTTOM: 3px; PADDING-LEFT: 2px; PADDING-RIGHT: 3px; PADDING-TOP: 3px; TEXT-DECORATION: none; WIDTH: 100%                                                                           " skip
    "\}                                                                                                                                                                                                              " skip
    "IMG.men1 \{                                                                                                                                                                                                     " skip
    "    BACKGROUND-COLOR: #95b2d6; HEIGHT: 1px; WIDTH: 140px                                                                                                                                                       " skip
    "\}                                                                                                                                                                                                              " skip.

put stream m-outdt unformatted
    "</STYLE>                                                           " skip
    "</HEAD>                                                            " skip.

put stream m-outdt unformatted
     "<SCRIPT LANGUAGE=""JavaScript"">                                                " skip
     "function GoToVM(v_num) \{                                                       " skip
     "                  parent.frames.fr2.location.href = 'valmon.html#'+ v_num;      " skip
     "\}                                                                              " skip.
put stream m-outdt unformatted
     "function GoToCRC(v_num) \{                                                       " skip
     "                  parent.frames.fr2.location.href = 'valmon.html#crc'+ v_num;   " skip    
     "\}                                                                              " skip
     "</SCRIPT>                                                                       " skip.

put stream m-out unformatted
    "INPUT \{" skip
    "    BACKGROUND-COLOR: #eeeeee; BORDER-BOTTOM: #9899c0 1px solid; BORDER-LEFT: #9899c0 1px solid; BORDER-RIGHT: #9899c0 1px solid; BORDER-TOP: #9899c0 1px solid; COLOR: #202020; FONT-FAMILY: verdana; FONT-SIZE: 8pt" skip
    "\}" skip
    "SELECT \{" skip
    "    BACKGROUND-COLOR: #eeeeee; BORDER-BOTTOM: #9899c0 1px solid; BORDER-LEFT: #9899c0 1px solid; BORDER-RIGHT: #9899c0 1px solid; BORDER-TOP: #9899c0 1px solid; COLOR: #202020; FONT-FAMILY: verdana; FONT-SIZE: 8pt" skip
    "\}                                                                                                                                                                                                                    " skip
    "OPTION \{                                                                                                                                                                                                             " skip
    "    BACKGROUND-COLOR: #eeeeee; BORDER-BOTTOM: #9899c0 1px solid; BORDER-LEFT: #9899c0 1px solid; BORDER-RIGHT: #9899c0 1px solid; BORDER-TOP: #9899c0 1px solid; COLOR: #202020; FONT-FAMILY: verdana; FONT-SIZE: 8pt" skip
    "\}                                                                                                                                                                                                                    " skip
    "TEXTAREA \{                                                                                                                                                                                                           " skip
    "    BACKGROUND-COLOR: #eeeeee; BORDER-BOTTOM: #9899c0 1px solid; BORDER-LEFT: #9899c0 1px solid; BORDER-RIGHT: #9899c0 1px solid; BORDER-TOP: #9899c0 1px solid; COLOR: #202020; FONT-FAMILY: verdana; FONT-SIZE: 8pt " skip
    "\}                                                                                                                                                                                                                      " skip
    "INPUT.nobrd \{                                                                                                                                                                                                          " skip
    "    BACKGROUND-COLOR: #ffffff; BORDER-BOTTOM: medium none; BORDER-LEFT: medium none; BORDER-RIGHT: medium none; BORDER-TOP: medium none " skip
    "\}                                                                                                                                       " skip
    "INPUT.buttons \{                                                                                                                         " skip.
put stream m-out unformatted
    "    BACKGROUND-COLOR: #ffffff; FONT-WEIGHT: bold; WIDTH: 150px                                                                          " skip
    "\}                                                                                                                                       " skip
    "H1 \{                                                                                                                                    " skip
    "    BACKGROUND-COLOR: #ffc972; COLOR: #202020; FONT-SIZE: 8pt; FONT-WEIGHT: bold; MARGIN: 0px 0px 10px; PADDING-BOTTOM: 1px; PADDING-LEFT: 3px; PADDING-RIGHT: 3px; PADDING-TOP: 3px; TEXT-TRANSFORM: uppercase" skip
    "\}                                                                                                                                                                                                              " skip
    "H2 \{                                                                                                                                                                                                           " skip
    "    BACKGROUND-COLOR: #ffc972; COLOR: #202020; FONT-SIZE: 8pt; FONT-WEIGHT: bold; MARGIN: 0px 0px 10px; PADDING-BOTTOM: 1px; PADDING-LEFT: 3px; PADDING-RIGHT: 3px; PADDING-TOP: 3px; TEXT-TRANSFORM: uppercase" skip
    "\}                                                                                                                                                                                                              " skip
    "H3 \{                                                                                                                                                                                                           " skip
    "    FONT-SIZE: 8pt; FONT-WEIGHT: bold; MARGIN: 0px; PADDING-BOTTOM: 3px; PADDING-LEFT: 0px; PADDING-RIGHT: 3px; PADDING-TOP: 3px                                                                               " skip.

put stream m-out unformatted
    "\}                                                                                                                                                                                                              " skip
    "HR \{                                                                                                                                                                                                           " skip
    "    COLOR: #95b2d6; HEIGHT: 1px; WIDTH: 100%                                                                                                                                                                   " skip
    "\}                                                                                                                                                                                                              " skip
    "A \{                                                                                                                                                                                                            " skip
    "    COLOR: #000099; TEXT-DECORATION: none                                                                                                                                                                      " skip
    "\}                                                                                                                                                                                                              " skip
    "A:hover \{                                                                                                                                                                                                      " skip
    "    TEXT-DECORATION: underline                                                                                                                                                                                 " skip
    "\}                                                                                                                                                                                                              " skip
    "A.tpbtn \{                                                                                                                                                                                                      " skip
    "    COLOR: #ffffff                                                                                                                                                                                             " skip
    "\}                                                                                                                                                                                                              " skip.

put stream m-out unformatted
    "A.tpbtn:visited \{                                                                                                                                                                                              " skip
    "    COLOR: #ffffff                                                                                                                                                                                             " skip
    "\}                                                                                                                                                                                                              " skip
    "A.tpbtn:active \{                                                                                                                                                                                               " skip
    "    COLOR: #ffffff                                                                                                                                                                                             " skip
    "\}                                                                                                                                                                                                              " skip
    "A.tpbtn:hover \{                                                                                                                                                                                                " skip
    "    COLOR: #3a5579                                                                                                                                                                                             " skip
    "\}                                                                                                                                                                                                              " skip
    ".yel \{                                                                                                                                                                                                         " skip
    "    backgorund-color: #FF0000                                                                                                                                                                                  " skip
    "\}                                                                                                                                                                                                              " skip
    ".thead \{                                                                                                                                                                                                       " skip
    "    COLOR: #949494                                                                                                                                                                                             " skip
    "\}                                                                                                                                                                                                              " skip
    "A.men1 \{                                                                                                                                                                                                       " skip.
put stream m-out unformatted
    "    COLOR: #020202; PADDING-BOTTOM: 3px; PADDING-LEFT: 2px; PADDING-RIGHT: 3px; PADDING-TOP: 3px; TEXT-DECORATION: none; WIDTH: 100%                                                                           " skip
    "\}                                                                                                                                                                                                              " skip
    "A.men1:visited \{                                                                                                                                                                                               " skip
    "    COLOR: #020202; PADDING-BOTTOM: 3px; PADDING-LEFT: 2px; PADDING-RIGHT: 3px; PADDING-TOP: 3px; TEXT-DECORATION: none; WIDTH: 100%                                                                           " skip
    "\}                                                                                                                                                                                                              " skip
    "A.men1:active \{                                                                                                                                                                                                " skip
    "    COLOR: #020202; PADDING-BOTTOM: 3px; PADDING-LEFT: 2px; PADDING-RIGHT: 3px; PADDING-TOP: 3px; TEXT-DECORATION: none; WIDTH: 100%                                                                           " skip
    "\}                                                                                                                                                                                                              " skip.
put stream m-out unformatted
    "A.men1:hover \{                                                                                                                                                                                                 " skip
    "    COLOR: #020202; PADDING-BOTTOM: 3px; PADDING-LEFT: 2px; PADDING-RIGHT: 3px; PADDING-TOP: 3px; TEXT-DECORATION: none; WIDTH: 100%                                                                           " skip
    "\}                                                                                                                                                                                                              " skip
    "IMG.men1 \{                                                                                                                                                                                                     " skip
    "    BACKGROUND-COLOR: #95b2d6; HEIGHT: 1px; WIDTH: 140px                                                                                                                                                       " skip
    "\}                                                                                                                                                                                                              " skip
    "</STYLE>                                                                                                                                                                                                       " skip
    "</HEAD>                                                                                                                                                                                                        " skip
    "<BODY bgColor=#ffffff marginwidth=0 marginheight=0 leftmargin=0 topmargin=0>                                                                                                                                   " skip
    "<TABLE border=0 cellPadding=0 cellSpacing=0 width=""100%"">                                                                                          " skip.


put stream m-outdt unformatted
    "<BODY bgColor=#ffffff marginwidth=0 marginheight=0 leftmargin=0 topmargin=0>                                                                                                                                   " skip.

put stream m-out unformatted
  "<TBODY>                                                                                        " skip
  "<TR vAlign=top>                                                                                " skip
  "  <TD width=""100%""><!-- BEGIN MAIN -->                                                       " skip.
put stream m-out unformatted
  "    <H1> <a name=""top"">  " string (g-today) " " string (time, "HH:MM:SS") "</a></H1> " skip.

put stream m-outdt unformatted
  "    <H1> <a name=""top"">  Валютный монитор " string (g-today) " " string (time, "HH:MM:SS") "</a></H1> " skip.

 v-text =  string(time, "HH:MM:SS") + " <--!BEGIN --> ".
 run lgps .

 v-text =  string(time, "HH:MM:SS") + " sw950pars парсер ".
 run lgps .

/* Парсим выписки */
run sw950pars. 

find last cls no-lock.
if avail cls then 
    v-clsday =  cls.whn. 
 else
    v-clsday =  g-today. 

 v-text =  string(time, "HH:MM:SS") + " vm-first.i ".
 run lgps .
 {vm-first.i}

 v-text =  string(time, "HH:MM:SS") + " vm-second.i ".
 run lgps .
 {vm-second.i}
 
 v-text =  string(time, "HH:MM:SS") + " vm-fird.i ".
 run lgps .
 {vm-fird.i}
 
 v-text =  string(time, "HH:MM:SS") + " vm-four.i ".
 run lgps .
 {vm-four.i}
 
 v-text =  string(time, "HH:MM:SS") + " vm-five.i ".
 run lgps .
 {vm-five.i}

 v-text =  string(time, "HH:MM:SS") + " vm-six.i ".
 run lgps .
 {vm-six.i}



put stream m-out unformatted
  "<!-- END MAIN --></TD></TR></TBODY></TABLE>                                                    " skip
  "<center><TABLE border=0 cellPadding=2 cellSpacing=0 width=""100%"">                            " skip
  "  <TBODY>                                                                                      " skip
  "  <TR>                                                                                         " skip
  "    <TD colSpan=2>                                                                             " skip
  "      <HR color=#95b2d6 noShade SIZE=1>                                                        " skip
  "    </TD></TR>                                                                                 " skip
  "  <TR align=left>                                                                              " skip
  "    <TD class=thead>Copyright c 2004 <A href=""http://www.texakabank.kz/""                     " skip
  "      target=_blank><B style=""BACKGROUND-COLOR: white; COLOR: red"">TEXAKA</B>                " skip.

put stream m-out unformatted
  "      <B style=""BACKGROUND-COLOR: white; COLOR: blue"">BANK</B></A></TD>                      " skip
  "</TR></TBODY></TABLE></BODY></HTML>                                                            " skip.

put stream m-outdt unformatted
  "             </TABLE></BODY></HTML>                                                            " skip.

output stream m-out close.
output stream m-outdt close.
/*
v-unidir = "Txb-a1297:C:\\\\Distr\\\\". 
*/


find sysc where sysc.sysc = "VALMPS" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   v-unidir = "NTMAIN:L:\\\\CAPITAL\\\\VALMON\\\\". 
end. else do :
   v-unidir = sysc.chval.
end.


v-text =  string(time, "HH:MM:SS") + " Begin copy to " + v-unidir.
run lgps .

input through value ("rcp " + "valmonhd.html" + " " + v-unidir + " ;echo $?" ). 
repeat:
  import v-result.
end.

input through value ("rcp " + "valmon.html" + " " + v-unidir + " ;echo $?" ). 
repeat:
  import v-result.
end.

v-text =  string(time, "HH:MM:SS") + " <--!END --> ".
run lgps .

pause 0.




