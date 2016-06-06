/* cifrep5.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        28/09/2011 evseev
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}


define temp-table wrk
   field namesp as char
   field dep as int
   field point as int
   field kas_op as decimal
   field perev as decimal
   field kurs_doh as decimal.

def var kas_op as decimal.
def var perev as decimal.
def var kurs_doh as decimal.
def var itog as decimal.

def var dt1 as date no-undo.
def var dt2 as date no-undo.

define frame fr
   skip(1)
   dt1      label 'C ' format '99/99/9999'
   dt2      label ' ПО' format '99/99/9999' skip
   with centered side-label row 5 title "УКАЖИТЕ ПЕРИОД ОТЧЕТА".

dt1 = g-today. dt2 = g-today.
update dt1 dt2 with frame fr.
hide frame fr.


empty temp-table wrk.

for each ppoint no-lock:
   create wrk.
     wrk.namesp = ppoint.name.
     wrk.dep = ppoint.dep.
     wrk.point = ppoint.point.
     wrk.kas_op = 0.
     wrk.perev = 0.
     wrk.kurs_doh = 0.
end.
/*****/
 function Convcrc returns decimal ( input sum as decimal, input c1 as int, input c2 as int, input d1 as date):
  define buffer bcrc1 for crchis.
  define buffer bcrc2 for crchis.
     if c1 <> c2 then do:
           find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt <= d1 no-lock no-error.
           find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt <= d1 no-lock no-error.
           if avail bcrc1 and avail bcrc2 then return sum * bcrc1.rate[1] / bcrc2.rate[1].
     end.
     else return sum.
 end function.
 function GetDate returns char ( input dt as date):
   return replace(string(dt,"99/99/9999"),"/",".").
 end function.
/*****/

def buffer bjl for jl.
def  var vpoint like point.point .
def  var vdep like ppoint.dep .
def var LN as char extent 8 initial ["[-|-]","[-/-]","[---]","[-\\-]","[-|-]","[-/-]","[---]","[-\\-]"].
def var i as int init 1.

for each jl where /*jl.sub = "cif" and jl.acc = b-aaa.aaa and*/ jl.jdt >= dt1 and jl.jdt <= dt2 and jl.dc = "c" no-lock:
     /*
    find first bjl where bjl.jh = jl.jh and bjl.gl = 287044 no-lock no-error.
    if not avail bjl then next.*/
    find first bjl where bjl.jh = jl.jh and bjl.gl = 453020 no-lock no-error.
    if avail bjl then do:
        if bjl.crc = 1 then kurs_doh = bjl.cam.
        else kurs_doh = Convcrc(bjl.cam , bjl.crc , 1 , bjl.jdt ).
        find first ofc where ofc.ofc = bjl.who no-lock no-error.
        if avail ofc then do:
           vpoint =  integer(ofc.regno / 1000).
           vdep = ofc.regno mod 1000.
           find first wrk where wrk.dep = vdep and wrk.point = vpoint no-lock no-error.
           if avail wrk then wrk.kurs_doh = wrk.kurs_doh + kurs_doh.
        end.
        else do: message "не найден кассир [1]". pause. end.
    end.
    find first bjl where bjl.jh = jl.jh and bjl.gl = 460122 no-lock no-error.
    if avail bjl then do:
        find first aaa where aaa.aaa = bjl.acc no-lock no-error.
        if avail aaa then next.
        if bjl.crc = 1 then perev = bjl.cam.
        else perev = Convcrc(bjl.cam , bjl.crc , 1 , bjl.jdt ).
        find first ofc where ofc.ofc = bjl.who no-lock no-error.
        if avail ofc then do:
           vpoint =  integer(ofc.regno / 1000).
           vdep = ofc.regno mod 1000.
           find first wrk where wrk.dep = vdep and wrk.point = vpoint no-lock no-error.
           if avail wrk then wrk.perev = wrk.perev + perev.
        end.
        else do: message "не найден кассир [2]". pause. end.
    end.

    hide message no-pause.
    message "Сбор данных - " LN[i].
    if i = 8 then i = 1.
    else i = i + 1.
end.

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
/*displ sys.chval*/
for each compaydoc where compaydoc.whn_cr >= dt1 and compaydoc.whn_cr <= dt2 and compaydoc.state = 2 and compaydoc.txb = sys.chval no-lock:
  kas_op = compaydoc.comm_summ.
  find first ofc where ofc.ofc = compaydoc.who_cr no-lock no-error.
  if avail ofc then do:
     vpoint =  integer(ofc.regno / 1000).
     vdep = ofc.regno mod 1000.
     find first wrk where wrk.dep = vdep and wrk.point = vpoint no-lock no-error.
     if avail wrk then wrk.kas_op = wrk.kas_op + kas_op.
  end.
  else do: message "не найден кассир [3]". pause. end.
  hide message no-pause.
  message "Сбор данных - " LN[i] " ".
  if i = 8 then i = 1.
  else i = i + 1.
end.

/*
OUTPUT TO cirep5.txt.
FOR EACH wrk:
EXPORT DELIMITER "^" wrk.
END.
*/

def stream cifrep5.

output stream cifrep5 to cifrep5.html.
{html-title.i
  &stream = " stream cifrep5 "
  &size-add = "1"
  &title = "Отчет по доходам физических лиц"
}

put  stream cifrep5 unformatted "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip.
put  stream cifrep5 unformatted "<tr><td align=center colspan=10><font size=""4""><b><a name="" ""></a> Отчет по доходам физических лиц  С " GetDate(dt1) " ПО " GetDate(dt2) "</b></font></td></tr>" skip.

put  stream cifrep5 unformatted "<TR style=""font:bold;font-size:11pt"">" skip
                 "<TD>" "Профит центр" "</TD>" skip
                 "<TD>" "Кассовые операции" "</TD>" skip
                 "<TD>" "Переводы в тенге" "</TD>" skip
                 "<TD>" "Курсовой доход" "</TD>" skip
                 "<TD>" "ИТОГО РКО" "</TD>" skip.

kas_op = 0.
perev = 0.
kurs_doh = 0.
itog = 0.
for each wrk no-lock:
   put  stream cifrep5 unformatted "<TR style=""font-size:10pt"">" skip
                "<TD>"  wrk.namesp "</TD>" skip
                "<TD>" replace(trim(string(wrk.kas_op,'>>>>>>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD>" replace(trim(string(wrk.perev,'>>>>>>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD>" replace(trim(string(wrk.kurs_doh,'>>>>>>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD>" replace(trim(string((wrk.kas_op + wrk.perev + wrk.kurs_doh),'>>>>>>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
  kas_op   =  kas_op   + wrk.kas_op.
  perev    =  perev    + wrk.perev.
  kurs_doh =  kurs_doh + wrk.kurs_doh.
  itog     =  itog     + wrk.kas_op + wrk.perev + wrk.kurs_doh.
end.

put  stream cifrep5 unformatted "<TR style=""font-size:10pt"">" skip
                "<TD>" "ИТОГ" "</TD>" skip
                "<TD>" replace(trim(string(kas_op,'>>>>>>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD>" replace(trim(string(perev,'>>>>>>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD>" replace(trim(string(kurs_doh,'>>>>>>>>>>>>>>>9.99')),'.',',') "</TD>" skip
                "<TD>" replace(trim(string(itog,'>>>>>>>>>>>>>>>9.99')),'.',',') "</TD>" skip.
put  stream cifrep5 unformatted "</table>" .
{html-end.i}
output stream cifrep5 close.
unix silent value ("cptwin cifrep5.html iexplore").
unix silent value ("rm cifrep5.html").