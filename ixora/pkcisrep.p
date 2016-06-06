/* pkcisrep.p
 * MODULE
        Потребительские кредиты
 * DESCRIPTION
        Отчет ЦИС
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
        28/04/2005 madiar
 * CHANGES
        26/05/2005 madiar - при отсутствии файла ответа выдается внятное сообщение об ошибке
*/

{global.i}
{pk.i}
if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and 
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

def var v-str as char.
def var v-res as char.
def var v-akifile as char.
def var v-akidirq as char.
def var v-akidira as char.
/*def var v-akidir as char.*/
def var v-akiscr as char.
def var v-akires as char.
def var v-qid as char.

def var time_st as integer.
def var time_end as integer.

def var cl_id as integer.
def var cl_name as char.
def var usrnm as char.
def var v-docq as integer init 0.

def stream aki_rep.

/* референс запроса   ггггммдд_время_РНН   */

if trim(pkanketa.rescha[2]) = '' or num-entries(pkanketa.rescha[2]) < 2 then do:
  message " Ошибка: данные о запросе отсутствуют " view-as alert-box buttons ok.
  return.
end.

/*
message pkanketa.rescha[2] view-as alert-box buttons ok.
*/

v-str = entry(1,pkanketa.rescha[2]).
v-qid = entry(2,pkanketa.rescha[2]).


{sysc.i}

v-akidirq = get-sysc-cha ("pkakiq").
v-akidira = get-sysc-cha ("pkakia").
v-akiscr = get-sysc-cha ("pkakis").
/*v-akidir = substr(v-akiscr, 1, r-index(v-akiscr, "/") - 1).*/

if substr(v-akidirq,length(v-akidirq),1) <> "/" then v-akidirq = v-akidirq + "/".
if substr(v-akidira,length(v-akidira),1) <> "/" then v-akidira = v-akidira + "/".
if substr(v-akiscr,length(v-akiscr),1) <> "/" then v-akiscr = v-akiscr + "/".

v-akidirq = v-akidirq + v-str.
v-akidira = v-akidira + v-str.

output stream aki_rep to pkcisout.htm.
put stream aki_rep unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.
    
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "lname" no-lock no-error.
cl_name = caps(trim(pkanketh.value1)).
find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "fname" no-lock no-error.
cl_name = cl_name + ' ' + caps(trim(pkanketh.value1)).
find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "mname" no-lock no-error.
if trim(pkanketh.value1) <> '' then cl_name = cl_name + ' ' + caps(trim(pkanketh.value1)).
find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "rnn" no-lock no-error. 
put stream aki_rep unformatted
    "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
    "<center><b>Отчет по запросу в ЦИС</b></center><BR><BR><BR>" skip
    "<b>Клиент:</b> " cl_name "<BR>" skip
    "<b>РНН:</b> " trim(pkanketh.value1) "<BR><BR>" skip.

v-akifile = v-akidirq + "q_" + v-qid + "_1".
v-akires  = v-akidira + "a_" + v-qid + "_1".

time_st = 0.
if num-entries(pkanketa.rescha[2]) > 2 then time_st = integer(entry(3,pkanketa.rescha[2])).
time_end = 0.
if num-entries(pkanketa.rescha[2]) > 3 then time_end = integer(entry(4,pkanketa.rescha[2])).

put stream aki_rep unformatted
    "<b>Запрос по номеру документа:</b><BR>" skip
    "Время отправки запроса: " string(time_st,"HH:MM:SS") "<BR>" skip
    "Время получения ответа: " string(time_end,"HH:MM:SS") "<BR>" skip
    "Период: " time_end - time_st " секунд(ы)<BR>" skip.
output stream aki_rep close.

v-res = ''.
input through value ("if [ -f " + v-akires + " ]; then echo 1; else echo 0; fi").
repeat:
  import v-res.
end.
pause 0.
if v-res = '0' then do:
  message " Произошла ошибка при получении ответа из ЦИС - файл с ответом не найден " view-as alert-box buttons ok.
  return.
end.

/*message " 1.... " v-res "   " cl_id view-as alert-box buttons ok.*/

run pkcisq1(v-akires, output cl_id).

/* если анализ ответа вернул id = -1 (клиент по номеру документа не найден), значит посылался запрос по имени/дате рождения */
if cl_id = -1 then do:
    
    v-akifile = v-akidirq + "q_" + v-qid + "_2".
    v-akires  = v-akidira + "a_" + v-qid + "_2".
    
    time_st = 0.
    if num-entries(pkanketa.rescha[2]) > 4 then time_st = integer(entry(5,pkanketa.rescha[2])).
    time_end = 0.
    if num-entries(pkanketa.rescha[2]) > 5 then time_end = integer(entry(6,pkanketa.rescha[2])).
    
    output stream aki_rep to pkcisout.htm append.
    put stream aki_rep unformatted
      "<b>Запрос по ФИО и дате рождения:</b><BR>" skip
      "Время отправки запроса: " string(time_st,"HH:MM:SS") "<BR>" skip
      "Время получения ответа: " string(time_end,"HH:MM:SS") "<BR>" skip
      "Период: " time_end - time_st " секунд(ы)<BR>" skip.
    output stream aki_rep close.
    
    v-res = ''.
    input through value ("if [ -f " + v-akires + " ]; then echo 1; else echo 0; fi").
    repeat:
      import v-res.
    end.
    pause 0.
    if v-res = '0' then do:
      message " Произошла ошибка при получении ответа из ЦИС - файл с ответом не найден " view-as alert-box buttons ok.
      return.
    end.
    
    /*message " 2.... " v-res "   " cl_id view-as alert-box buttons ok.*/
    
    run pkcisq2(v-akires, output cl_id).
    
    v-docq = 2.
    
end.

if cl_id = -1 then do:
  unix silent cptwin pkcisout.htm excel.
  return.
end.

v-akifile = v-akidirq + "q_" + v-qid + "_3".
v-akires  = v-akidira + "a_" + v-qid + "_3".

time_st = 0.
if num-entries(pkanketa.rescha[2]) > 4 + v-docq then time_st = integer(entry(5 + v-docq,pkanketa.rescha[2])).
time_end = 0.
if num-entries(pkanketa.rescha[2]) > 5 + v-docq then time_end = integer(entry(6 + v-docq,pkanketa.rescha[2])).

output stream aki_rep to pkcisout.htm append.
put stream aki_rep unformatted
   "<b>Запрос по недвижимости:</b><BR>" skip
   "Время отправки запроса: " string(time_st,"HH:MM:SS") "<BR>" skip
   "Время получения ответа: " string(time_end,"HH:MM:SS") "<BR>" skip
   "Период: " time_end - time_st " секунд(ы)<BR>" skip.
output stream aki_rep close.

v-res = ''.
input through value ("if [ -f " + v-akires + " ]; then echo 1; else echo 0; fi").
repeat:
  import v-res.
end.
pause 0.
if v-res = '0' then do:
  message " Произошла ошибка при получении ответа из ЦИС - файл с ответом не найден " view-as alert-box buttons ok.
  return.
end.

/*message " 3.... " v-res "   " cl_id view-as alert-box buttons ok.*/

run pkcisq3(v-akires).

unix silent cptwin pkcisout.htm excel.
