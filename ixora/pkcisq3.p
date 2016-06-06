/* pkcisq3.p
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
        24/07/2007 madiyar - cl_id2 теперь char, так как в integer возвращаемое число уже не влезает
*/

{global.i}
{pk0.i}

def input parameter v-akires as char no-undo.

def stream aki_rep.
def stream r-in.

def var v-txt as char no-undo.
def var carr as char no-undo extent 20.
def var coun as integer no-undo.
def var rec_coun as integer no-undo.
def var curr_loc as char no-undo init ''.
def var sts as integer no-undo.
def var cl_id2 as char no-undo.

def var res_lst as char no-undo extent 5 init ['1 – полное совпадение','2 – совпадение только блока регистрации','3 – совпадение только блока по недвижимости в собственности','4 – полное несовпадение','5 – отсутствие данных'].
def var res2_lst as char no-undo extent 3 init ['1 – совпадение','2 – несовпадение','3 – отсутствие данных'].

output stream aki_rep to pkcisout.htm append.
input stream r-in from value(v-akires).

coun = 0. rec_coun = 0.
repeat:
  
  import stream r-in unformatted v-txt.
  v-txt = trim(v-txt).
  
  if coun = 0 then do:
    if index(v-txt,"undef") > 0 then do:
      sts = -1.
      leave.
    end.
  end.
  
  if index(v-txt,"$VAR1") > 0 then rec_coun = rec_coun + 1.
  if index(v-txt,"realty") > 0 then curr_loc = "realty".
  if index(v-txt,"residence") > 0 then curr_loc = "residence".
  if index(v-txt,"},") > 0 then curr_loc = ''.
  
  if num-entries(v-txt,"''") >= 4 then do:
    case entry(2,v-txt,"''"):
      
      when "id" then do: carr[1] = entry(4,v-txt,"''"). cl_id2 = trim(carr[1]). end.
      when "executionStatus" then carr[2] = entry(4,v-txt,"''").
      
      when "patronymic" then carr[5] = entry(4,v-txt,"''").
      when "birthDate" then carr[6] = entry(4,v-txt,"''").
      when "surname" then carr[3] = entry(4,v-txt,"''").
      when "name" then carr[4] = entry(4,v-txt,"''").
      when "birthPlace" then carr[7] = entry(4,v-txt,"''").
      
      when "houseComparStatus" then do:
        if curr_loc = "realty" then carr[9] = entry(4,v-txt,"''").
        if curr_loc = "residence" then carr[15] = entry(4,v-txt,"''").
      end.
      when "streetComparStatus" then do:
        if curr_loc = "realty" then carr[8] = entry(4,v-txt,"''").
        if curr_loc = "residence" then carr[13] = entry(4,v-txt,"''").
      end.
      when "flatComparStatus" then do:
        if curr_loc = "realty" then carr[10] = entry(4,v-txt,"''").
        if curr_loc = "residence" then carr[17] = entry(4,v-txt,"''").
      end.
      
      when "roomsNumber" then carr[11] = entry(4,v-txt,"''").
      when "streetName" then carr[12] = entry(4,v-txt,"''").
      when "houseNumber" then carr[14] = entry(4,v-txt,"''").
      when "flatNumber" then carr[16] = entry(4,v-txt,"''").
      
      when "beginDate" then carr[18] = entry(4,v-txt,"''").
      when "residenceType" then carr[19] = entry(4,v-txt,"''").
      when "relationToOwner" then carr[20] = entry(4,v-txt,"''").
    end case.
  end.
  
  if index(v-txt,"};") > 0 and rec_coun = 2 then do:
    put stream aki_rep unformatted "<table border=1 cellpadding=0 cellspacing=0>" skip.
    
    if carr[1] <> '' then 
       put stream aki_rep unformatted
          "<tr><td style=""font:bold"">Запрос вернул ID клиента</td>" skip
          "<td>" carr[1] "</td></tr>" skip.
    
    put stream aki_rep unformatted
       "<tr><td style=""font:bold"">Статус выполнения запроса</td>" skip
       "<td>" res_lst[integer(carr[2])] "</td></tr>" skip
       "<tr><td style=""font:bold"">ФИО клиента</td>" skip
       "<td>" carr[3] " " carr[4] if carr[5] <> "" then " " else "" carr[5] "</td></tr>" skip
       "<tr><td style=""font:bold"">Дата рождения</td>" skip
       "<td>" carr[6] "</td></tr>" skip.
    
    if carr[7] <> '' then 
       put stream aki_rep unformatted
          "<tr><td style=""font:bold"">Место рождения</td>" skip
          "<td>" carr[7] "</td></tr>" skip.
    
    put stream aki_rep unformatted
       "<tr><td style=""font:bold"" colspan=2 align=""center"">Недвижимость в собственности</td></tr>" skip
       "<tr><td style=""font:bold"">Статус сверки улицы</td>" skip
       "<td>" res2_lst[integer(carr[8])] "</td></tr>" skip
       "<tr><td style=""font:bold"">Статус сверки дома</td>" skip
       "<td>" res2_lst[integer(carr[9])] "</td></tr>" skip
       "<tr><td style=""font:bold"">Статус сверки квартиры</td>" skip
       "<td>" res2_lst[integer(carr[10])] "</td></tr>" skip.
    
    if carr[11] <> '' then 
       put stream aki_rep unformatted
          "<tr><td style=""font:bold"">Количество комнат</td>" skip
          "<td>" carr[11] "</td></tr>" skip.
    
    put stream aki_rep unformatted
       "<tr><td style=""font:bold"" colspan=2 align=""center"">Регистрация</td></tr>" skip
       "<tr><td style=""font:bold"">Улица</td>" skip
       "<td>" carr[12] "</td></tr>" skip
       "<tr><td style=""font:bold"">Статус сверки улицы</td>" skip
       "<td>" res2_lst[integer(carr[13])] "</td></tr>" skip
       "<tr><td style=""font:bold"">Дом</td>" skip
       "<td>" carr[14] "</td></tr>" skip
       "<tr><td style=""font:bold"">Статус сверки дома</td>" skip
       "<td>" res2_lst[integer(carr[15])] "</td></tr>" skip
       "<tr><td style=""font:bold"">Квартира</td>" skip
       "<td>" carr[16] "</td></tr>" skip
       "<tr><td style=""font:bold"">Статус сверки квартиры</td>" skip
       "<td>" res2_lst[integer(carr[17])] "</td></tr>" skip
       "<tr><td style=""font:bold"">Дата начала регистрации</td>" skip
       "<td>" carr[18] "</td></tr>" skip
       "<tr><td style=""font:bold"">Тип регистрации</td>" skip
       "<td>" carr[19] "</td></tr>" skip
       "<tr><td style=""font:bold"">Родственные отношения</td>" skip
       "<td>" carr[20] "</td></tr>" skip
       "</table><BR>" skip.
    carr = "".
  end.
  
  coun = coun + 1.
  
end.

input stream r-in close.

if sts = -1 then put stream aki_rep unformatted "ОШИБКА: <BR><BR>" skip.

output stream aki_rep close.


