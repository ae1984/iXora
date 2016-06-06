/* pkzayavcc.p
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

/* pkzayavcc.p ПотребКредит
   Печать заявления на получение карточки - Кредитные карточки

   Сам текст берется из файла zayavcc.html в каталоге /data/alm/export/dpk/docs, 
   затем в него подставляются данные из анкеты

   19.06.2003 nadejda
   23.07.2003 nadejda - поменяла выбор пути к шаблону заявления на путь базы + каталог (т.е. каталог свой для каждого филиала)
   18.05.05 marinav - для депозит+карточка теперь берется общий файл
   19/04/2006 madiyar - перенос договоров на сервера филиалов
   08/09/2006 madiyar - убрал fdf
*/


{global.i}
{pk.i}

/*
s-credtype = "4".
s-pkankln = 29.
*/

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and 
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then return.

if pkanketa.sts < "10" then do:
  message skip " Документы не оформлены !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

def stream v-out.

def var v-ofile as char.
def var v-ifile as char.
def var v-infile as char.
def var v-str as char.
def var v-lname as char.
def var v-fname as char.
def var v-mname as char.
def var v-params as char init 
"
lname|lname,fname|fname,mname|mname,
numpas|docnum,dtpas|dbd,dtpas|dbm,dtpas|dby,
partner|kktype1,partner|kktype2,partner|kktype3,crc|kkcrc1,crc|kkcrc2,
ofc|ofc,profitcn|profitcn,v-typecc|v-typecc".
def var i as integer.
def var v-param as logical.

def temp-table t-params 
  field kritcod as char
  field paramfind as char
  field data as char
  index main is primary unique kritcod paramfind.

do i = 1 to num-entries(v-params):
  v-str = entry(i, v-params).
  create t-params.
  t-params.kritcod = entry(1, v-str, "|").
  t-params.paramfind = entry(2, v-str, "|").
end.

for each t-params:
  find pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and
    pkanketh.kritcod = t-params.kritcod no-lock no-error.
  if avail pkanketh then t-params.data = caps(pkanketh.value1).

  case t-params.kritcod:
    when "dtpas" then do:
        case t-params.paramfind:
          when "dbd" then t-params.data = string(day(date(t-params.data)), "99").
          when "dbm" then t-params.data = string(month(date(t-params.data)), "99").
          when "dby" then t-params.data = string(year(date(t-params.data)), "9999").
        end case.
      end.
    when "partner" then do:
        i = integer (substr (t-params.paramfind, length(t-params.paramfind), 1)).
        if i = integer (pkanketa.partner) then t-params.data = "X".
      end.
    when "crc" then do:
        i = integer (substr (t-params.paramfind, length(t-params.paramfind), 1)).
        if i = pkanketa.crc then t-params.data = "X".
      end.
    when "ofc" then do:
      find ofc where ofc.ofc = pkanketa.rwho no-lock no-error.
      v-str = entry (1, trim(ofc.name), " ").
      if num-entries (trim(ofc.name), " ") > 1 and trim (entry (2, trim(ofc.name), " ")) <> "" then
        v-str = v-str + " " + substring (entry (2, trim (ofc.name), " "), 1, 1) + ".".
      if num-entries (trim(ofc.name), " ") > 2  and trim (entry (3, trim(ofc.name), " ")) <> "" then
        v-str = v-str + substring (entry (3, trim(ofc.name), " "), 1, 1) + ".".

      t-params.data = caps (v-str).
      end.
    when "v-typecc" then do:
         if pkanketa.goal = 'VISA30' then t-params.data = 'Visa 30'.
                                     else t-params.data = 'Credit Card'. 

      end.
    when "profitcn" then do:
      find last ofcprofit where ofcprofit.ofc = pkanketa.rwho and ofcprofit.regdt <= pkanketa.rdt no-lock no-error.
      if avail ofcprofit then v-str = ofcprofit.profitcn.
      else do:
        find ofc where ofc.ofc = pkanketa.rwho no-lock no-error.
        v-str = ofc.titcd.
      end.
      find codfr where codfr.codfr = "sproftcn" and codfr.code = v-str no-lock no-error.
      v-str = caps (trim (codfr.name[1])).
      t-params.data = v-str.
    end.
  end case.

  v-str = t-params.data.
  t-params.data = substring(v-str, 1, 1).
  do i = 2 to length(v-str):
    t-params.data = t-params.data + "&nbsp;" + substring(v-str, i, 1).
  end.
  t-params.data = replace (t-params.data, " ", "&nbsp;").

  if t-params.data = "" then t-params.data = "&nbsp;". 
end.

/* печать заявления на получение карточки */
/* 25.07.03 suchkov добавил выбор анкеты */ 
/*find t-params where t-params.paramfind = "kktype1" .
if t-params.data = "X" then v-infile = "zayavcc-vg.htm" . else v-infile = "zayavcc-vcve.htm".
*/

if pkanketa.sernom = "" then v-infile = "zayavcc.html" .
                        else v-infile = "zayavcc-vcve.htm" . 

v-ofile = "zayavcc.htm".
output stream v-out to value(v-ofile).

{pk-sysc.i}

v-ifile = get-pksysc-char ("dcdocs").
if not v-ifile begins "/" then v-ifile = "/" + v-ifile.
if substr (v-ifile, length(v-ifile), 1) <> "/" then v-ifile = v-ifile + "/".
v-ifile = v-ifile + v-infile .

input from value(v-ifile).
repeat:
  import unformatted v-str.
  v-str = trim(v-str).

  /* заменить параметры на данные клиента */
  c-param:
  repeat:
    v-param = false.
    for each t-params:
      if v-str matches "*\{\&" + t-params.paramfind + "\}*" then do:
        v-param = true.

        v-str = replace (v-str, "\{\&" + t-params.paramfind + "\}", t-params.data).

      end.
    end.
    if not v-param then leave c-param.
  end.
  put stream v-out unformatted v-str skip.
end.

input close.
output stream v-out close.
/* 25.07.03 suchkov поменял word на excel */ 
if pkanketa.sernom <> "" then unix silent value("cptwin " + v-ofile + " excel").
else unix silent value("cptwin " + v-ofile + " winword").


