/* r-klaf.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       30/10/2008 madiyar - перекомпиляция
*/

define shared variable g-today as date.
define variable gaidiet as character init "Минутку...".
define variable druka as logical label "Печать ?".
define variable npk as integer.
define variable v-grp as integer.
define variable mes as character extent 12 init
       ["января","февраля","марта","апреля","мая","июня","июля","августа",
        "сентября","октября","ноября","декабря"].

define temp-table wkl
       field    grp   as integer
       field    name  as character
       field    fun   like fun.fun
       field    amt   as decimal
       field    int   as decimal
       field    uzk-n as decimal
       field    uzk-f as decimal
       field    ndr-f as decimal.
define temp-table wkls
       field    grp   as integer
       field    name  as character
       field    amt   as decimal
       field    int   as decimal
       field    uzk-n as decimal
       field    uzk-f as decimal
       field    ndr-f as decimal.

define stream s1.
define stream s2.

define variable vprint as logical init true.
define variable vappend as logical init true.
define variable dest as character.

dest = "prit".
update vappend label "Продолжать ?.." skip
       vprint  label "Печатать ?...." skip
       dest    label "Команда печати" format "x(30)" skip
       with row 5 centered side-label frame image1.

if not vprint 
then return.

display "               "
        gaidiet no-label format "x(13)" with frame image1.

find sysc where sysc.sysc = ">F01CA" no-lock.

for each fun where fun.dam[1] > fun.cam[1] no-lock:
    find gl where gl.gl = fun.gl no-lock.
    if gl.type <> "A"
    then next.
    if index(sysc.chval,string(fun.gl)) > 0
    then next.
    find crc where crc.crc = fun.crc no-lock.
    create wkl.
    wkl.fun = fun.fun.
    find sub-cod where sub-cod.sub = "FUN" and sub-cod.acc = fun.fun and 
         sub-cod.d-cod = "klmbd" no-lock no-error.
    if available sub-cod
    then wkl.grp = integer(sub-cod.ccode).
    else wkl.grp = 0.
    wkl.uzk-n = round(wkl.grp * crc.rate[1] * (fun.dam[1] - fun.cam[1]) / 
                      100 / 1000 / crc.rate[9],3).
    find trxbal where trxbal.subled =  "FUN" and trxbal.acc = fun.fun and 
         trxbal.level = 3 and trxbal.crc = fun.crc no-lock no-error.
    if available trxbal
    then wkl.uzk-f = round(crc.rate[1] * (trxbal.cam - trxbal.dam) / 
                     1000 / crc.rate[9],3).
    else wkl.uzk-f = 0.
    find trxbal where trxbal.subled = "FUN" and trxbal.acc = fun.fun and
         trxbal.level = 6 and trxbal.crc = fun.crc no-lock no-error.
    if available trxbal
    then wkl.ndr-f = round(crc.rate[1] * (trxbal.dam - trxbal.cam) / 
                     1000 / crc.rate[9],3).
    else wkl.ndr-f = 0.
    wkl.name = fun.cst.
    wkl.amt = round(crc.rate[1] * (fun.dam[1] - fun.cam[1]) / 
              1000 / crc.rate[9],3).
    wkl.int = round(crc.rate[1] * fun.dam[2] / 1000 / crc.rate[9],3).
    find first wkls where wkls.grp = wkl.grp no-error.
    if not available wkls
    then do:
         create wkls.
         wkls.grp = wkl.grp.
         find codfr where codfr.codfr = "klmbd" and codfr.code = 
             string(wkl.grp,"999") no-lock.
         wkls.name = codfr.name[1].
    end.
    wkls.amt = wkls.amt + wkl.amt.
    wkls.int = wkls.int + wkl.int.
    wkls.uzk-n = wkls.uzk-n + wkl.uzk-n.
    wkls.uzk-f = wkls.uzk-f + wkl.uzk-f.
    wkls.ndr-f = wkls.ndr-f + wkl.ndr-f.
    find first wkls where wkls.grp = 999 no-error.
    if not available wkls
    then do:
         create wkls.
         wkls.grp = 999.
    end.
    wkls.amt = wkls.amt + wkl.amt.
    wkls.int = wkls.int + wkl.int.
    wkls.uzk-n = wkls.uzk-n + wkl.uzk-n.
    wkls.uzk-f = wkls.uzk-f + wkl.uzk-f.
    wkls.ndr-f = wkls.ndr-f + wkl.ndr-f.
end.

if vappend
then output stream s1 to rpt.img append.
else output stream s1 to rpt.img.

put stream s1 
    "Классификация депозитов и формирование провизий по ним" at 45 skip
    "АО ""ТехаКаBank""  на " at 45 
    day(g-today) format "z9" " " mes[month(g-today)]
    year(g-today) format "zzz9" " года" skip(2).
put stream s1 "( тыс. тенге )" at 100 skip.
put stream s1 
    "------"
    "-------------------------------"
    "-----------"
    "----------------"
    "----------------"
    "----------------"
    "----------------"
    "----------------"
    "----------------" skip.
put stream s1 
    ":    :"
    "                              :"
    "          :"
    "   Основной    :"
    "  Начисленное  :"
    " Размер резерва:"
    "  Необходимая  :"
    "  Фактически   :"
    "   Стоимость   :" skip.
put stream s1 
    ":    :"
    "                              :"
    "          :"
    "     долг      :"
    " вознаграждение:"
    " (в % от суммы :"
    "    сумма      :"
    " сформированные:"
    "  обеспечения  :" skip.

put stream s1 
    ": NN :"
    "       Д Е П О З И Т Ы        :"
    "   Номер  :"
    "               :"
    "   (интерес)   :"
    "основного долга:"
    "   провизий    :"
    "   провизии    :"
    "               :" skip.

put stream s1 
    ":    :"
    "                              :"
    "   сделки :"
    "               :"
    "               :"
    "   согласно    :"
    "               :"
    "               :"
    "               :" skip.

put stream s1 
    ":    :"
    "                              :"
    "          :"
    "               :"
    "               :"
    "   Положения)  :"
    "               :"
    "               :"
    "               :" skip.
put stream s1 
    ":    :"
    "                              :"
    "          :"
    "---------------:"
    "---------------:"
    "---------------:"
    "---------------:"
    "---------------:"
    "---------------:" skip.
put stream s1 
    ":    :"
    "                              :"
    "          :"
    "     гр.1      :"
    "     гр.2      :"
    "     гр.3      :"
    "     гр.4      :"
    "     гр.5      :"
    "     гр.6      :" skip.
put stream s1 
    ":-----"
    "-------------------------------"
    "-----------"
    "----------------"
    "----------------"
    "----------------"
    "----------------"
    "----------------"
    "---------------:" skip.


v-grp = -1.
npk = 0.
for each wkl by wkl.grp:
    if wkl.grp <> v-grp
    then do:
         if v-grp >= 0
         then do:
              put stream s1 
                  ":----:"
                  "------------------------------:"
                  "----------:"
                  "---------------:"
                  "---------------:"
                  "---------------:"
                  "---------------:"
                  "---------------:"
                  "---------------:" skip.

              put stream s1
                  ":    :"
                  " В С Е Г О" format "x(30)" ":"
                  "          :"
                  wkls.amt format "zzz,zzz,zzz,zzz" ":"
                  wkls.int format "zzz,zzz,zzz,zzz" ":"
                  wkls.grp format "zzzzzzzz9" "      :"
                  wkls.uzk-n format "zzz,zzz,zzz,zzz" ":"
                  wkls.uzk-f format "zzz,zzz,zzz,zzz" ":"
                  wkls.ndr-f format "zzz,zzz,zzz,zzz" ":" skip.

              put stream s1 
                  ":-----"
                  "-------------------------------"
                  "-----------"
                  "----------------"
                  "----------------"
                  "----------------"
                  "----------------"
                  "----------------"
                  "---------------:" skip.
         end.
         v-grp = wkl.grp.
         find first wkls where wkls.grp = v-grp.
         put stream s1 ":  "
             wkls.name format "x(34)"
             "           "
             "                "
             "                "
             "                "
             "                "
             "                "
             "               :" skip.
         put stream s1 
             ":-----"
             "-------------------------------"
             "-----------"
             "----------------"
             "----------------"
             "----------------"
             "----------------"
             "----------------"
             "---------------:" skip.
    end.
    npk = npk + 1.
    put stream s1
        ":" npk format "zzz9" ":"
        wkl.name format "x(30)" ":"
        wkl.fun format "x(10)"  ":"
        wkl.amt format "zzz,zzz,zzz,zzz" ":"
        wkl.int format "zzz,zzz,zzz,zzz" ":"
        wkl.grp format "zzzzzzzz9" "      :"
        wkl.uzk-n format "zzz,zzz,zzz,zzz" ":"
        wkl.uzk-f format "zzz,zzz,zzz,zzz" ":"
        wkl.ndr-f format "zzz,zzz,zzz,zzz" ":" skip.

end.
put stream s1 
    ":----:"
    "------------------------------:"
    "----------:"
    "---------------:"
    "---------------:"
    "---------------:"
    "---------------:"
    "---------------:"
    "---------------:" skip.

put stream s1
           ":    :"
           " В С Е Г О" format "x(30)" ":"
           "          :"
           wkls.amt format "zzz,zzz,zzz,zzz" ":"
           wkls.int format "zzz,zzz,zzz,zzz" ":"
           wkls.grp format "zzzzzzzz9" "      :"
           wkls.uzk-n format "zzz,zzz,zzz,zzz" ":"
           wkls.uzk-f format "zzz,zzz,zzz,zzz" ":"
           wkls.ndr-f format "zzz,zzz,zzz,zzz" ":" skip.

put stream s1 
    ":-----"
    "-------------------------------"
    "-----------"
    "----------------"
    "----------------"
    "----------------"
    "----------------"
    "----------------"
    "---------------:" skip.
find first wkls where wkls.grp = 999.
put stream s1
    ":    :"
    " И Т О Г О" format "x(30)" ":"
    "          :"
    wkls.amt format "zzz,zzz,zzz,zzz" ":"
    wkls.int format "zzz,zzz,zzz,zzz" ":"
    "               :"
    wkls.uzk-n format "zzz,zzz,zzz,zzz" ":"
    wkls.uzk-f format "zzz,zzz,zzz,zzz" ":"
    wkls.ndr-f format "zzz,zzz,zzz,zzz" ":" skip.
put stream s1 
    "------"
    "-------------------------------"
    "-----------"
    "----------------"
    "----------------"
    "----------------"
    "----------------"
    "----------------"
    "----------------" skip.
output stream s1 close.
unix silent value(dest) rpt.img.
