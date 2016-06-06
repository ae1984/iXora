﻿/* pkcisq2.p
 * MODULE
        Потребительские кредиты
 * DESCRIPTION
        Обработка ответа на запрос по ФИО и дате рождения
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
        07/04/2005 madiyar
 * CHANGES
        11/05/2005 madiyar - добавил pk0.i для автоматической перекомпиляции
        04/06/2007 madiyar - запросы возвращают id клиентов слишком большие для типа integer, сделал char
*/

{global.i}
{pk0.i}

def input parameter v-akires as char no-undo.
def output parameter cl_id as char no-undo.

def stream aki_rep.
def stream r-in.

def var v-txt as char no-undo.
def var carr as char no-undo extent 12.
def var coun as integer no-undo.
def var i as integer no-undo.
def var doc_coun as integer no-undo.

output stream aki_rep to pkcisout.htm append.
input stream r-in from value(v-akires).

coun = 0. doc_coun = 0.
repeat:
  
  import stream r-in unformatted v-txt.
  v-txt = trim(v-txt).
  
  if coun = 0 then do:
    if index(v-txt,"undef") > 0 then do:
      cl_id = "-1".
      leave.
    end.
  end.
  
  if index(v-txt,"documents") > 0 then doc_coun = 1.
  if v-txt = "}," then doc_coun = doc_coun + 1.
  
  if num-entries(v-txt,"''") >= 4 then do:
    case entry(2,v-txt,"''"):
      when "patronymic" then carr[4] = entry(4,v-txt,"''").
      when "id" then do: carr[1] = entry(4,v-txt,"''"). cl_id = trim(carr[1]). end.
      when "birthDate" then carr[5] = entry(4,v-txt,"''").
      when "surname" then carr[2] = entry(4,v-txt,"''").
      when "birthPlace" then carr[6] = entry(4,v-txt,"''").
      when "name" then carr[3] = entry(4,v-txt,"''").
      when "issueAgency" then if doc_coun < 2 then carr[9] = entry(4,v-txt,"''"). else carr[9] = carr[9] + '^' + entry(4,v-txt,"''").
      when "issueDate" then if doc_coun < 2 then carr[10] = entry(4,v-txt,"''"). else carr[10] = carr[10] + '^' + entry(4,v-txt,"''").
      when "expirationDate" then if doc_coun < 2 then carr[11] = entry(4,v-txt,"''"). else carr[11] = carr[11] + '^' + entry(4,v-txt,"''").
      when "signActual" then if doc_coun < 2 then carr[12] = entry(4,v-txt,"''"). else carr[12] = carr[12] + '^' + entry(4,v-txt,"''").
      when "type" then if doc_coun < 2 then carr[7] = entry(4,v-txt,"''"). else carr[7] = carr[7] + '^' + entry(4,v-txt,"''").
      when "number" then if doc_coun < 2 then carr[8] = entry(4,v-txt,"''"). else carr[8] = carr[8] + '^' + entry(4,v-txt,"''").
    end case.
  end.
  
  if index(v-txt,"};") > 0 then do:
    put stream aki_rep unformatted
       "<table border=1 cellpadding=0 cellspacing=0>" skip
       "<tr><td style=""font:bold"">ID клиента</td>" skip
       "<td>" carr[1] "</td></tr>" skip
       "<tr><td style=""font:bold"">ФИО клиента</td>" skip
       "<td>" carr[2] " " carr[3] if carr[4] <> "" then " " else "" carr[4] "</td></tr>" skip
       "<tr><td style=""font:bold"">Дата рождения</td>" skip
       "<td>" carr[5] "</td></tr>" skip
       "<tr><td style=""font:bold"">Место рождения</td>" skip
       "<td>" carr[6] "</td></tr>" skip.
    
    do i = 1 to num-entries(carr[8],"^"):
      put stream aki_rep unformatted
         "<tr><td style=""font:bold"">Тип документа (3 - удост., 4 - паспорт)</td>" skip
         "<td>" if num-entries(carr[7],"^") >= i then entry(i,carr[7],"^") else "" "</td></tr>" skip
         "<tr><td style=""font:bold"">Номер документа</td>" skip
         "<td>" entry(i,carr[8],"^") "</td></tr>" skip
         "<tr><td style=""font:bold"">Документ выдан</td>" skip
         "<td>" if num-entries(carr[9],"^") >= i then entry(i,carr[9],"^") else "" "</td></tr>" skip
         "<tr><td style=""font:bold"">Дата выдачи документа</td>" skip
         "<td>" if num-entries(carr[10],"^") >= i then entry(i,carr[10],"^") else "" "</td></tr>" skip
         "<tr><td style=""font:bold"">Дата окончания срока действия документа</td>" skip
         "<td>" if num-entries(carr[11],"^") >= i then entry(i,carr[11],"^") else "" "</td></tr>" skip
         "<tr><td style=""font:bold"">Признак актуальности документа</td>" skip
         "<td>" if num-entries(carr[12],"^") >= i then entry(i,carr[12],"^") else "" "</td></tr>" skip.
    end.
    put stream aki_rep unformatted "</table><BR>" skip.
    carr = "". doc_coun = 0.
  end.
  
  coun = coun + 1.
  
end.

input stream r-in close.

if cl_id = "-1" then put stream aki_rep unformatted "ОШИБКА: Физическое лицо не найдено<BR><BR>" skip.

output stream aki_rep close.
