/* check_photos.p
 * MODULE
        Потребительские кредиты
 * DESCRIPTION
        Проверка на наличие фотографий
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
        01/08/2005 madiyar
 * CHANGES
        02/08/2005 madiyar - добавил проверку на ".jpg"
        20/06/2006 madiyar - переделал под ssh, но пока только для актобе
        04/09/2006 madiyar - ssh уральск
        28/09/2006 madiyar - ssh атырау
        05/03/2007 madiyar - для всех - scp
        31/10/2008 madiyar - альтернативная директория для загрузки фотографий
*/

{global.i}
{sysc.i}

def output parameter res as integer no-undo.
def output parameter wdir as integer no-undo.
res = 0.
wdir = 0.

def var v-phdirs as char no-undo.
def var v-phdirs1 as char no-undo.
v-phdirs = get-sysc-cha ("pkphs").
v-phdirs1 = v-phdirs.

if substr(v-phdirs,length(v-phdirs),1) <> "/" then v-phdirs = v-phdirs + "/".
v-phdirs = v-phdirs + string(year(today),"9999") + string(month(today),"99") + string(day(today),"99") + "/".

def var v-txt as char.
def var coun as integer.
def stream s1.

def var s-ourbank as char.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
  message " Нет записи OURBNK в таблице sysc !!".
  pause.
  return.
end.
else s-ourbank = sysc.chval.

input stream s1 through value("ssh Administrator@`askhost` dir /b \\""" + replace(v-phdirs,'/',"\\\\") + "*.jpg\\""").
coun = 0.
repeat:
  import stream s1 unformatted v-txt.
  if trim(v-txt) <> '' and index(trim(v-txt),".jpg") > 0 then coun = coun + 1.
end.
input stream s1 close.

if coun <= 0 then do:
    input stream s1 through value("ssh Administrator@`askhost` dir /b \\""" + replace(v-phdirs1,'/',"\\\\") + "*.jpg\\""").
    coun = 0.
    repeat:
      import stream s1 unformatted v-txt.
      if trim(v-txt) <> '' and index(trim(v-txt),".jpg") > 0 then coun = coun + 1.
    end.
    input stream s1 close.
    if coun > 0 then wdir = 2.
end.
else wdir = 1.

res = coun.

