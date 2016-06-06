/* dinv.p
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

/* dinv.p */

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

define new shared variable nam as character extent 60 initial [
    "UZKR…JUMI SAIST.UN MAKS…JUM.",
    "2.L§DZEK¶I KONTOS",
    "2.1.norё±inu konti jur.pers.",
    "2.2.depozЁtu konti jur.pers.",
    "2.3.norё±inu konti fiz.pers.",             /*05*/
    "2.4.depozЁtu konti fiz.pers.",
    "2.5.jurid.p.eks/imp.dar.",
    "2.6.fiz.p.eks/imp.dar.",
    "3.LORO KONTI",
    "4.OVERDRAFTS",                             /*10*/
    "5.SAISTI§B.PRET A/S RKB",
    "5.1.sa‡em.no c/o kredЁti",
    "5.2.no cit. fili–lёm",
    "5.3.nauda ceµ–",
    "5.4.no a/s RKB sa‡em. avansi",             /*15*/
    "6.P…RЁJIE PAS§VI",
    "7.N…K.PER.IEN.un UZKR.IZDEVUMI",
    "8.PIESAIST§T. DEPOZ§TI",
    "KOP…",
    "1.PRASIBAS PRET NEBANKAM",                 /*20*/
    "1.1.OVERDRAFTS KLIENTU KONTOS",            
    "2.KRED§TI",
    "2.1.ilgtermi‡a jur.pers.",
    "2.2.Ёstermi‡a jur.pers.",
    "2.3.ilgtermi‡a fiz.pers.",                 /*25*/
    "2.4.Ёstermi‡a fiz.pers.",                  
    "2.5.ilgterm.kredЁti darbiniekiem",
    "2.6.kontokorent.kred.",
    "3.P…RDOTIE RESURSI",
    "3.1.c/o izsniegtie kredЁti",               /*30*/
    "3.2.fili–lёm",                             
    "4.OVERDRAFTS",
    "5.KASE",
    "6.CITAS PRAS.PRET KRED§TIES.",
    "6.1.ўeki",                                 /*35*/
    "6.2.kredЁtkartes",                         
    "6.3 val­ta ceµ–",
    "7.IZVIET.DEPOZ§TI",
    "8.N…K.PER.IZM.UN UZKR.IEN…K.",
    "9.P…RЁJIE AKT§VI",                         /*40*/
    "10.KONVERTЁ№ANAS RЁґINS",                  
    "KOP…",
    "KOR.KONTS PЁC BILANCES" ].                 /*43*/

def var selec as char format "x(15)" extent 2 initial
    ["ATSKAITE", "SKAјO№ANA"].

repeat on endkey undo, leave:
{mainhead.i}

disp selec with no-labels row 4 attr-space frame zq centered no-box.
choose field selec with frame zq.

if frame-index = 2 then do:
   hide all.
   run dinc-set(43,"DINVAL").
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
vtitle = "BILANCES DINAMIKA  (VAL®TA)  PAR  " + string (ddate).

if sal then do:
    fname = filename + fcha[1].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinval (input fname, input "SALASPILS").    end.
end.
if ola then do:
    fname = filename + fcha[2].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinval (input fname, input "OLAINE").       end.
end.
if ces then do:
    fname = filename + fcha[3].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinval (input fname, input "CЁSIS").        end.
end.
if jur then do:
    fname = filename + fcha[4].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinval (input fname, input "J®RMALA").      end.
end.
if dgl then do:
    fname = filename + fcha[5].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinval (input fname, input "DAUGAVPILS").   end.
end.
if jek then do:
    fname = filename + fcha[6].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinval (input fname, input "JЁKABPILS").    end.
end.
if bol then do:
    fname = filename + fcha[7].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinval (input fname, input "BOLDERAJA").    end.
end.
if rez then do:
    fname = filename + fcha[8].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinval (input fname, input "RЁZEKNE").      end.
end.
if lie then do:
    fname = filename + fcha[9].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinval (input fname, input "LIEP…JA").      end.
end.
if ven then do:
    fname = filename + fcha[10].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinval (input fname, input "VENTSPILS").    end.
end.
if val then do:
    fname = filename + fcha[11].
	if search (fname) eq ? then do:
	    message fname + "  nav atrasts !".
	    pause.
	end.
	else do:
	    run dinval (input fname, input "VALMIERA").     end.
end.

{report3.i}
{imageja3.i}
end. /*frame-index = 1*/
end. /*repeat*/
