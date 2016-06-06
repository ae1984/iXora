/* syscmp.p
 * MODULE
        Настройка банковского профиля
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
        25.12.2002 nadejda - добавлен ОКПО и прописаны русские названия
 * CHANGES
        07.01.2004 valery - Добавлено поле для наименования по английски
        11.02.2004 suchkov - Добавлено поле e-mail для отправки балансов по городам.
        26.06.2006 u00121  - Увлеичил формат до двух цифр для поля cmp.code в форме фрайма f-cmp
        21.04.2008 alex - Добавлено поле для наименования каз. Расширил фрейм, увеличил форматы.
        22/05/2008 madiyar - Расширил поля для ввода
        18/11/09   marinav - убрана проверка на числовой значение счета и БИКа
        08.06.10 marinav - добавлен БИН
*/

{mainhead.i}

def var msg-err as char init " Введенное значение содержит нецифровые символы!".
def var v-i as integer.
def var v-bankbik as char.
def var v-bankiik as char.
def var v-bankups as char.
def var v-bankbin as char.
def var v-zip as char.
def var v-fax as char.
def var v-telex as char.
def var v-swift as char.
def var v-email as char.
def var v-mailb as char.
def var v-engname as char.
def var v-engaddr as char.
def var v-engcity as char.
def var v-engcntry as char.
def var v-kazname as char.
def var v-kazaddr as char.
def var v-kazcity as char.
def var v-kazcntry as char.


function is-int returns logical (p-value as char).
  def var vp-i as deci.
  def var vp-l as logical init true.
  vp-i = decimal(p-value) no-error.
  if ERROR-STATUS:ERROR then vp-l = false.
  return vp-l.
end.

form 
  cmp.name format "x(1000)" view-as fill-in size 90 by 1 label "Наименование" help " Наименование банка/филиала" colon 15 skip
  cmp.addr[2] format "x(12)" label "РНН" help " РНН - 12 цифр" colon 15
      validate (is-int(trim(cmp.addr[2])), msg-err) 
  v-bankiik format "x(20)" label "ИИК (кор.счет)" help " ИИК (кор.счет) банка - 20 цифр"
      colon 50 skip
  cmp.addr[3] format "x(12)" label "ОКПО" help " ОКПО - 12 цифр (8 - ОКПО банка, 4 - признак филиала)" colon 15
      validate (is-int(trim(cmp.addr[3])), msg-err)
  v-bankbik format "x(9)" label "БИК (МФО)" help " БИК (МФО) банка - 9 цифр" 
      colon 50 skip
  v-bankbin format "x(12)" label "БИН" help " БИН - 12 цифр" colon 15
      validate (is-int(trim(v-bankbin)), msg-err) 
  v-bankups format "x(3)" label "Код в УПС" help " Код банка в УПС НБ РК - 3 цифры" colon 50
      validate (is-int(trim(v-bankups)), msg-err) skip(1)

  v-zip format "x(6)" label "Индекс" help " Почтовый индекс" colon 15 skip
  cmp.addr[1] format "x(90)" label "Адрес" help " Полный адрес" colon 15 skip
  cmp.tel label "Тел." format "(xxxx) xxx-xxx" help " Телефон RECEPTION (укажите код города)" colon 15 
  v-fax format "(xxxx) xxx-xxx" label "Факс" help " Номер факса" colon 50 skip
  cmp.contact label "Контакт" format "x(90)" help " Контактное лицо (RECEPTION)" colon 15 skip

  v-telex format "x(20)" label "Телекс" help " Код телекса" colon 15
  v-swift format "x(15)" label "S.W.I.F.T." help " Код банка в системе S.W.I.F.T." colon 50 skip
  v-email format "x(1000)" view-as fill-in size 90 by 1 label "E-mail" help " Адрес эл.почты для общих писем" colon 15 skip
  v-mailb format "x(1000)" view-as fill-in size 90 by 1 label "E-mail бал." help " Адрес эл.почты для рассылки балансов" colon 15

  skip(1)
  v-engname format "x(1000)" view-as fill-in size 84 by 1 label "Наименование (англ)" help "Наименование по английски" colon 21 skip
  v-engaddr format "x(1000)" view-as fill-in size 90 by 1 label "Адрес (англ)" help " Адрес в британском формате" colon 15 skip
  v-engcity format "x(1000)" view-as fill-in size 90 by 1 label "Город (англ)" help " Название города по-английски" colon 15 skip
  v-engcntry format "x(1000)" view-as fill-in size 90 by 1 label "Страна (англ)" help " Название страны по-английски" colon 15
 
  skip(1)
  v-kazname format "x(1000)" view-as fill-in size 84 by 1 label "Наименование (каз)" help "Наименование на казахском" colon 21 skip
  v-kazaddr format "x(1000)" view-as fill-in size 90 by 1 label "Адрес (каз)" help " Адрес каз" colon 15 skip
  v-kazcity format "x(1000)" view-as fill-in size 90 by 1 label "Город (каз)" help " Название города на казахском" colon 15 skip
  v-kazcntry format "x(1000)" view-as fill-in size 90 by 1 label "Страна (каз)" help " Название страны на казахском" colon 15

  skip(1)
  cmp.code format "99" label "Код офиса" help " Код офиса в платежной системе (0 - центральный, 1, 2, 3... - филиалы)" colon 15
  with width 110 side-label centered row 3 title " БАНКОВСКИЙ ПРОФИЛЬ " frame f-cmp.

find sysc where sysc.sysc = "clecod" no-lock no-error.
if avail sysc then v-bankbik = sysc.chval.

find sysc where sysc.sysc = "bnkiik" no-lock no-error.
if avail sysc then v-bankiik = sysc.chval.

find sysc where sysc.sysc = "bnkups" no-lock no-error.
if avail sysc then v-bankups = sysc.chval.

find sysc where sysc.sysc = "bnkbin" no-lock no-error.
if not avail sysc then do:
      create sysc. sysc.sysc = 'BNKBIN'.  sysc.des = 'БИН банка'.
end.
v-bankbin = sysc.chval.

find sysc where sysc.sysc = "bnkadr" no-lock no-error.
if avail sysc then do:
  v-zip = entry(1, sysc.chval, "|") no-error.
  v-fax = entry(2, sysc.chval, "|") no-error.
  v-telex = entry(3, sysc.chval, "|") no-error.
  v-swift = entry(4, sysc.chval, "|") no-error.
  v-email = entry(5, sysc.chval, "|") no-error.
  v-mailb = entry(6, sysc.chval, "|") no-error.
  v-engaddr = entry(7, sysc.chval, "|") no-error.
  v-engcity = entry(8, sysc.chval, "|") no-error.
  v-engcntry = entry(9, sysc.chval, "|") no-error.
  v-engname = entry(10, sysc.chval, "|") no-error.
  v-kazaddr = entry(11, sysc.chval, "|") no-error.
  v-kazcity = entry(12, sysc.chval, "|") no-error.
  v-kazcntry = entry(13, sysc.chval, "|") no-error.
  v-kazname = entry(14, sysc.chval, "|") no-error.
end.

find first cmp exclusive-lock no-error.
if not available cmp then create cmp.

update cmp.name cmp.addr[2] cmp.addr[3] v-bankbin v-bankiik v-bankbik v-bankups
       v-zip cmp.addr[1] cmp.tel v-fax cmp.contact
       v-telex v-swift v-email v-mailb v-engname v-engaddr v-engcity v-engcntry v-kazname v-kazaddr v-kazcity v-kazcntry
       cmp.code 
  with frame f-cmp.

find current cmp no-lock.

if v-zip entered or v-fax entered or v-telex entered or v-swift entered or
   v-email entered or v-mailb entered or v-engname entered or v-engaddr entered or v-engcity entered or v-engcntry entered 
   or v-kazname entered or v-kazaddr entered or v-kazcity entered or v-kazcntry entered then do:
   
  find sysc where sysc.sysc = "bnkadr" exclusive-lock no-error.
  if not avail sysc then do:
    create sysc.
    assign sysc.sysc = "BNKADR"
           sysc.des  = "Данные о банке/офисе (визитка)".
  end.

  sysc.chval = v-zip + "|" + 
               v-fax + "|" +
               v-telex + "|" +
               v-swift + "|" +
               v-email + "|" +
               v-mailb + "|" +
               v-engaddr + "|" +
               v-engcity + "|" +
               v-engcntry + "|" +
               v-engname + "|" +
               v-kazaddr + "|" +
               v-kazcity + "|" +
               v-kazcntry + "|" +
           v-kazname.
  
  release sysc.
end.

if v-bankbik entered then do:
  find sysc where sysc.sysc = "clecod" exclusive-lock no-error.
  if not avail sysc then do:
    create sysc.
    assign sysc.sysc = "CLECOD"
           sysc.des  = "МФО банка (БИК)".
  end.

  sysc.chval = v-bankbik.

  release sysc.
end.

if v-bankiik entered then do:
  find sysc where sysc.sysc = "bnkiik" exclusive-lock no-error.
  if not avail sysc then do:
    create sysc.
    assign sysc.sysc = "BNKIIK"
           sysc.des  = "Кор.счет банка (ИИК)".
  end.

  sysc.chval = v-bankiik.

  release sysc.
end.

if v-bankups entered then do:
  find sysc where sysc.sysc = "bnkups" exclusive-lock no-error.
  if not avail sysc then do:
    create sysc.
    assign sysc.sysc = "BNKUPS"
           sysc.des  = "Код банка в УПС НБ РК".
  end.

  sysc.chval = v-bankups.

  release sysc.
end.

if v-bankbin entered then do:
  find sysc where sysc.sysc = "bnkbin" exclusive-lock no-error.
  if not avail sysc then do:
    create sysc.
    assign sysc.sysc = "BNKBIN"
           sysc.des  = "БИН банка".
  end.
  sysc.chval = v-bankbin.

  release sysc.
end.

/* прописать РНН и ОКПО в параметры банка в базе COMM */
if cmp.addr[2] entered or cmp.addr[3] entered then do:
  if not connected ("comm") then run comm-con.
  for each txb where txb.txb = cmp.code exclusive-lock transaction:
    if num-entries(txb.params) < 2 then txb.params = txb.params + ",".
    entry(1, txb.params) = cmp.addr[2].
    entry(2, txb.params) = cmp.addr[3].
  end.
end.