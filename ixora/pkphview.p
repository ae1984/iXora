/* pkphlink.p
 * MODULE
        Потребительские кредиты
 * DESCRIPTION
        Привязка фотографий к анкете
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
        02/08/2005 madiyar
 * CHANGES
        27/09/2005 madiyar - добавил Атырау
        29/09/2005 madiyar - добавил Уральск
        12/10/2005 madiyar - работают все филиалы
        21/06/2006 madiyar - переделал под ssh, но пока только для актобе
        12/09/2006 madiyar - ssh уральск
        28/09/2006 madiyar - ssh атырау
        05/03/2007 madiyar - для всех - scp
        11/02/2009 madiyar - сменили локаль в линухе, перестала отрабатывать проверка на отсутствие файлов, исправил
*/

{global.i}
{sysc.i}
{pk.i}

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then do:
  message " Анкета не найдена! " view-as alert-box buttons ok title " Ошибка! ".
  return.
end.

def temp-table wrk
  field dname as char
index idx is primary dname.

def var v-str as char init ''.
def var coun as integer.
def var v-phdird as char.
v-phdird = get-sysc-cha ("pkphd").

if substr(v-phdird,length(v-phdird),1) <> "/" then v-phdird = v-phdird + "/".
v-phdird = v-phdird + s-credtype + "/" + string(year(pkanketa.rdt)) + "/" + string(month(pkanketa.rdt)) + "/".

input through value("if [ ! -d " + v-phdird + " ]; then echo 0; else echo 1").
repeat:
  import v-str.
end.
pause 0.

if v-str = "0" then do:
  message " Некорректная дата регистрации анкеты! " view-as alert-box buttons ok title " Ошибка! ".
  return.
end.

def stream s1.
input stream s1 through value("ls " + v-phdird + trim(string(s-pkankln,">>>>>9")) + "*.jpg | awk 'BEGIN\{FS=""/""\}\{print $NF\}'").

repeat:
  import stream s1 unformatted v-str.
  if index(v-str,"No such file or directory") > 0 or index(v-str,"Нет такого файла или каталога") > 0 then do:
    message " Нет привязанных фотографий! " view-as alert-box buttons ok title " Внимание! ".
    return.
  end.
  create wrk.
  wrk.dname = v-str.
end.

/*
for each wrk:
displ wrk.sname format "x(30)" wrk.dname format "x(30)".
end.
*/

   unix silent value("scp -q " + v-phdird + trim(string(s-pkankln,">>>>>9")) + "*.jpg Administrator@`askhost`:" + replace(s-tempfolder,"\\","/")).
/*
else
   unix silent value("rcp " + v-phdird + trim(string(s-pkankln,">>>>>9")) + "*.jpg `askhost`:" + replace(s-tempfolder,"\\","//")).
*/


def stream rep.
output stream rep to rep_img.htm.

put stream rep unformatted
    "<html><head>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
    "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
    "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
    "</head><body>" skip.

coun = 0.
for each wrk no-lock:
  coun = coun + 1.
  put stream rep unformatted "<img border=0 src=""" wrk.dname """>" skip.
  if (coun mod 2) = 0 then put stream rep unformatted "<br>" skip.
end.

put stream rep unformatted "</body></html>" skip.
output stream rep close.

unix silent cptwin rep_img.htm iexplore.
