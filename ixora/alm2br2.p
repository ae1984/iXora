/* alm2br2.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Копирование шаблона с базы Алматы на базы филиалов
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
        08/12/2004 madiyar
 * CHANGES
        28/02/2008 madiyar - небольшие изменения
*/

def input parameter v-templ as char.
def input parameter allbr as logi.
def var ja as logi init yes.

form skip(1)
     " " txb.cmp.name " " ja " " skip
     skip(1)
     with no-label centered row 7 frame fr.

find first txb.cmp no-lock no-error.

if not allbr then do:
  displ txb.cmp.name ja with frame fr.
  update ja go-on(F4) with frame fr.
end.

hide frame fr.
hide message no-pause.

if keyfunction(lastkey) = "end-error" or not ja then do:
  message " " txb.cmp.name " - копирование отменено ".
  return.
end.


find txb.trxhead where txb.trxhead.System = substring(v-templ,1,3) and txb.trxhead.code = integer(substring(v-templ,4,4)) no-error.
if avail txb.trxhead then do:
  find first txb.trxtmpl where txb.trxtmpl.code = v-templ no-lock no-error.
  if avail txb.trxtmpl then do:
    message " " + txb.cmp.name + " - Шаблон существует. Заменить?"
              view-as alert-box question buttons ok-cancel title "" update choice as logical.
    if not choice then do: message " " txb.cmp.name " - копирование отменено ". return. end.
    else delete txb.trxhead.
  end.
end.
for each txb.trxtmpl where txb.trxtmpl.code = v-templ:
  delete txb.trxtmpl.
end.
for each txb.trxlabs where txb.trxlabs.code = v-templ:
  delete txb.trxlabs.
end.
for each txb.trxcdf where txb.trxcdf.trxcode = v-templ:
  delete txb.trxcdf.
end.


find bank.trxhead where bank.trxhead.System = substring(v-templ,1,3) and bank.trxhead.code = integer(substring(v-templ,4,4)) no-lock no-error.
if avail bank.trxhead then do:
  create txb.trxhead.
  buffer-copy bank.trxhead to txb.trxhead.
end.
for each bank.trxtmpl where bank.trxtmpl.code = v-templ no-lock:
  create txb.trxtmpl.
  buffer-copy bank.trxtmpl to txb.trxtmpl.
end.
for each bank.trxlabs where bank.trxlabs.code = v-templ no-lock:
  create txb.trxlabs.
  buffer-copy bank.trxlabs to txb.trxlabs.
end.
for each bank.trxcdf where bank.trxcdf.trxcode = v-templ no-lock:
  create txb.trxcdf.
  buffer-copy bank.trxcdf to txb.trxcdf.
end.

if not allbr then message " " txb.cmp.name " - копирование произведено ".
