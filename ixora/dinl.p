/* dinl.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

define variable answer as logical.
define variable filename as character.
define variable fname as character.
define variable ddate as date.
define variable sal as logical label "SALASPILS".
define variable ola as logical label "OLAINE".
define variable ces as logical label "CЁSIS".
define variable jur as logical label "J®RMALA".
define variable dgl as logical label "DAUGAVPILS".
define variable jek as logical label "JЁKABPILS".
define variable bol as logical label "BOLDERAJA".
define variable rez as logical label "RЁZEKNE".
define variable lie as logical label "LIEP…JA".
define variable ven as logical label "VENTSPILS".
define variable val as logical label "VALMIERA".
define new shared variable fcha as character extent 11 initial [
    "sal", "ola", "ces", "jur", "dgl", "jek",
    "bol", "rez", "lie", "ven", "val" ].
def var selec as char format "x(15)" extent 2 initial
    ["ATSKAITE", "SKAјO№ANA"].

define new shared variable nam as character extent 60 initial [
    "1.IEPRIEK№.PER.NESAD.PE¶јA",
    "1.1.ATSKAT.GADA T§RA PE¶јA",
    "2.PA№U KAPIT…LS",
    "2.1.akciju kapit–ls",
    "2.2.rezerves kapit–ls",                /* 05 */
    "2.3.emisijas uzcenojums",
    "2.4.–rz.val­tas p–rv.rezerve",
    "2.5.iepriekЅёjo gadu nesad.peµ‡a",
    "3.UZKR…JUMI SAIST.UN MAKS…JUM.",
    "4.L§DZEK¶I KONTOS",                    /*10*/
    "4.1.norё±inu konti jur.pers.",
    "4.2.depozЁtu konti jur.pers.",
    "4.3.norё±inu konti fiz.pers.",
    "4.4.depozЁtu konti fiz.pers.",
    "4.5.jurid.p.eks/imp.dar.",             /*15*/
    "4.6.fiz.p.eks/imp.dar.",
    "5.LORO KONTI",
    "6.OVERDRAFTS",
    "7.SAISTIB.PRET A/S RKB",
    "7.1.sa‡em.no c/o kredЁti",             /*20*/
    "7.2.no cit. fili–lёm",
    "7.3.nauda ceµ–",
    "7.4.no a/s RKB sa‡em. avansi",
    "8.P…RЁJAS SAIST. PRET BANK…M",
    "9.PIESAIST. DEPOZ§TI",                 /*25*/
    "10.P…RЁJIE PAS§VI",
    "11.N…K.PER.IEN.un UZKR.IZDEVUMI",
    "KOP…",
    "1.PRAS§BAS PRET NEBANKAM",
    "1.1.OVERDRAFRTS KLIENTU KONTOS",       /*30*/
    "1.2.KRED§TI",
    "1.ilgtermi‡a jur.pers.",
    "2.Ёstermi‡a jur.pers.",
    "3.ilgtermi‡a fiz.pers.",
    "4.Ёstermi‡a fiz.pers.",                /*35*/
    "5.ilgterm.kredЁti darbiniekiem",
    "6.Ёsterm.kred.darbiniekiem",
    "7.kontokorent.kredЁti",
    "1.3.L§ZINGS",
    "1.4.CESIJAS",                          /*40*/
    "1.5.SPEKULAT§VAS INVESTIC.",
    "2.L§DZDAL§BA",
    "3.P…RDOTIE RESURSI",
    "3.1.cit–m bank–m",
    "3.2.fili–lёm",                         /*45*/
    "4.OVERDRAFTS",
    "5.IZVIET.DEPOZ§TI",
    "6.VALSTS OBLIG…CIJAS",
    "7.KASE",
    "8.CITAS PRAS PRЁT KRED§TIEST.",        /*50*/
    "8.1.ўeki",
    "8.2.kredЁtkartes",
    "8.3.val­ta ceµ–",
    "9.N…K.PER.IZM.UN UZKR.IEN…K.",
    "10.P…RЁJIE AKT§VI",                    /*55*/
    "11.KONVERTЁ№ANAS RЁґINS",
    "12.IEPRIEK№.PER.T§RIE ZAUDЁJUMI",
    "13.ATSKAIT.GADA T§RIEZAUDЁJUMI",
    "KOP…",
    "KOR.KONTS PЁC BILANCES" ].             /*60*/

repeat on endkey undo, leave:
{mainhead.i}

disp selec with no-labels row 4 attr-space frame zq centered no-box.
choose field selec with frame zq.

if frame-index = 2 then do:
   hide all.
   run dinc-set(60,"DINLAT").
end.
else do:
form sal ola ces jur dgl jek bol rez lie ven val
    with frame fil 2 col title "FILI…LES" centered row 4.

find sysc where sysc.sysc eq "bildin" no-lock no-error.
    if not available sysc then do:
	message "fail– sysc nav atrasts  bildin (direktorijas nosaukums) !".
	return.
    end.
    else
	filename = sysc.chval.


message "MainЁt parametrus" update answer.
    if answer then do:
	update fcha[1] label "SALASPILS" fcha[2] label "OLAINE"
	    fcha[3] label "CЁSIS" fcha[4] label "J®RMALA"
	    fcha[5] label "DAUGAVPILS" fcha[6] label "JЁKABPILS"
	    fcha[7] label "BOLDERAJA" fcha[8] label "RЁZEKNE"
	    fcha[9] label "LIEP…JA" fcha[10] label "VENTSPILS"
	    fcha[11] label "VALMIERA"
	    with frame ans side-labels 2 col title "PARAMETRI".

	hide frame ans.
    end.


update ddate label "DATUMS" validate (ddate ne ?, "")
    with frame dt side-labels centered no-box overlay.
filename = filename + "bil" +
    string (day (ddate), "99") + string (month (ddate), "99") + ".".


update sal ola ces jur dgl jek bol rez lie ven val with frame fil.

{image1.i rpt.img}
{image2.i}
{report1.i 60}
{report2.i 60}
vtitle = "BILANCES DINAMIKA  (LATI)  PAR  " + string (ddate).

if sal then do:
       fname = filename + fcha[1].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinlat (input fname, input "SALASPILS").    end.
end.
if ola then do:
    fname = filename + fcha[2].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinlat (input fname, input "OLAINE").       end.
end.
if ces then do:
    fname = filename + fcha[3].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinlat (input fname, input "CЁSIS").        end.
end.
if jur then do:
    fname = filename + fcha[4].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinlat (input fname, input "J®RMALA").      end.
end.
if dgl then do:
    fname = filename + fcha[5].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinlat (input fname, input "DAUGAVPILS").   end.
end.
if jek then do:
    fname = filename + fcha[6].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinlat (input fname, input "JЁKABPILS").    end.
end.
if bol then do:
    fname = filename + fcha[7].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinlat (input fname, input "BOLDERAJA").    end.
end.
if rez then do:
    fname = filename + fcha[8].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinlat (input fname, input "RЁZEKNE").      end.
end.
if lie then do:
    fname = filename + fcha[9].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinlat (input fname, input "LIEP…JA").      end.
end.
if ven then do:
    fname = filename + fcha[10].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinlat (input fname, input "VENTSPILS").    end.
end.
if val then do:
    fname = filename + fcha[11].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinlat (input fname, input "VALMIERA").     end.
end.


{report3.i}
{imageja3.i}
end. /*frame-index = 1*/
end. /*repeat*/
