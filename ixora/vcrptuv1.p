/* vcrptuv1.p
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

/* vcrptuv1.p - Валютный контроль 
   Уведомление о паспорте сделки/доплисте

   10.12.2002 nadejda создан
   20.06.2003 nadejda добавлен выбор таможенного управления по номеру паспорта сделки
   29/12/2005 nataly  - добавила наименование РКО и ФИО директоров
*/

{vc.i}

{global.i}
{comm-txb.i}

def input parameter p-docs like vcps.ps.
def buffer b-vcps for vcps.
def var v-vcourbank as char.
def var v-city as char.
def var v-num as char.
def var v-namedl as char init "доп.лист".
def var v-name as char.
def var v-bankname as char.
def var v-accname as char.
def var v-posname as char.
def var v-i as integer.
def var v-datastr as char.
def var v-str as char.
def var v-custom as char.
def var v-dep2 as char.
def var v-datastrkz as char no-undo.

find vcps where vcps.ps = p-docs no-lock no-error.
v-num = trim(vcps.dnnum).
if vcps.dntype = "19" then do:
  find first b-vcps where b-vcps.contract = vcps.contract and b-vcps.dntype = "01" no-lock no-error.
  if avail b-vcps then do:
    if index(v-num, trim(b-vcps.dnnum)) = 0 then v-num = trim(b-vcps.dnnum) + ", N " + v-num.
    else do:
      if index(v-num, ", N ") = 0 then do:
        for each b-vcps where b-vcps.contract = vcps.contract and b-vcps.dntype = "19" and 
             b-vcps.dndate <= vcps.dndate and 
             ((b-vcps.dnnum < vcps.dnnum) or 
             (b-vcps.dnnum = vcps.dnnum) and (b-vcps.ps < vcps.ps)) 
             no-lock use-index main:
          accumulate b-vcps.ps (count).
        end.
        v-num = v-num + ", N " + string((accum count b-vcps.ps) + 1).
      end.
    end.
    v-i = index(v-num, ", N ").
    v-num = substring(v-num, 1, v-i) + " " + v-namedl + substring(v-num, v-i + 1).
  end.
  else do:
    v-i = index(v-num, ", N ").
    if v-i = 0 then v-num = v-namedl + " N " + v-num.
    else  v-num = substring(v-num, 1, v-i) + " " + v-namedl + substring(v-num, v-i + 1).
  end.
end.
find vccontrs where vccontrs.contract = vcps.contract no-lock no-error.
find cif where cif.cif = vccontrs.cif no-lock no-error. 

find first cmp no-lock no-error.
if avail cmp then do:
  v-bankname = cmp.name.
  v-city = entry(1, cmp.addr[1]).
end.

v-custom = " Таможенное управление по " + v-city.
/* попробуем определить таможенное управление из номера ПС */
v-str = entry(2, vcps.dnnum, "/").
if length(v-str) = 8 then do:
  find codfr where codfr.codfr = "customs" and codfr.code <> "msc" and codfr.code = substring(v-str, 4, 5) no-lock no-error.
  if avail codfr then v-custom = codfr.name[1].
end.

/*find sysc where sysc.sysc = "vc-dep" no-lock no-error.
if avail sysc then do: 
  v-name = entry(1, sysc.chval).
  v-posname = entry(2, sysc.chval).
end.*/

  v-dep2 = string(int(cif.jame) - 1000) .
  find first codfr where codfr = 'vchead' and codfr.code = v-dep2 no-lock no-error .
  if avail codfr and codfr.name[1] <> "" then  do: 
    v-name = entry(2, trim(codfr.name[1])).
    v-posname = entry(1, trim(codfr.name[1])).
  end.
  

def stream vcrpt.
output stream vcrpt to vcuv.htm.

{html-title.i 
 &stream = " stream vcrpt "
 &title = " "
 &size-add = " "
}

if vccontrs.expimp = "e" then
  v-accname = "зачисления экспортной выручки по контрактам (договорам, соглашениям и т.д.)".
else 
  v-accname = "оплаты контрактов (договоров, соглашений и т.д.)".

run pkdefdtstr (g-today, output v-datastr, output v-datastrkz).

put stream vcrpt unformatted 
  "<P align=""right""><IMG border=""0"" src=""http://www.texakabank.kz/images/top_logo_bw.gif""><BR><BR><BR></P>" skip
  "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip
    "<TR align=""left"" valign=""top"">" skip
      "<TD width=""30%"">" v-datastr "</TD>" skip
      "<TD width=""10%"">&nbsp;</TD>"
      "<TD align=""right"">" v-custom "</TD></TR></TABLE>" skip
  "<P>&nbsp;<BR><BR><BR></P>" skip
  "<P align = ""center""><FONT size=""3"" face=""Times New Roman Cyr, Verdana, sans"">"
  "<B>УВЕДОМЛЕНИЕ</B></FONT></P>" skip
  "<P align=""justify""><FONT face=""Times New Roman Cyr, Verdana, sans"">" 
  v-bankname 
  " сообщает, что " skip
  trim(trim(cif.prefix) + " " + trim(cif.name)) skip
  "имеет текущий валютный счет для " 
  v-accname 
  " N<BR><BR>" skip
  "1) " 
  vccontrs.ctnum 
  " от " 
  string(vccontrs.ctdate, "99/99/9999") 
  ", паспорт сделки N " skip
  v-num 
  "</P><P>&nbsp;</P>" skip
  "<P align=""justify"">Подпись лица, имеющего право первой подписи, соответствует образцам подписей.</P>" skip 
  "<P>&nbsp;</P>" skip
  "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip
    "<TR align=""left"" valign=""top"">" skip
      "<TD width=""30%"">" 
      v-posname 
      "<BR>" 
      v-bankname 
      "</TD>" skip
      "<TD width=""40%"">&nbsp;</TD>"
      "<TD width=""30%"">" 
      v-name 
      "</TD></TR></TABLE>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin vcuv.htm iexplore").

pause 0.

