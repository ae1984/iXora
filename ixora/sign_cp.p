/* sign_cp.p
 * MODULE
        Потребительские кредиты - замена подписей
 * DESCRIPTION
        Копирование подписи и локальных параметров профиля в действующие
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
        11/06/2008 madiyar
 * BASES
        BANK COMM
 * CHANGES
        11/08/2008 madiyar - заголовок у сообщения об успешном копировании был "error", исправил
        18/07/2011 evseev - изменения в sign_common.i
*/

{global.i}

def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

{sign_common.i}

def var v-who as integer no-undo.
v-who = 0.

{itemlist.i
    &file = "t-faces"
    &frame = "row 6 centered scroll 1 12 down overlay "
    &where = " true "
    &flddisp = " t-faces.code label 'КОД' format '>9'
                 t-faces.face label 'НАИМЕНОВАНИЕ' format 'x(64)'
               "
    &chkey = "code"
    &chtype = "integer"
    &index  = "idx"
    &end = "if keyfunction(lastkey) = 'end-error' then return."
}
v-who = t-faces.code.

def var i as integer no-undo.
def var err as integer no-undo init 0.

do i = 1 to num-entries(spr_list):

    find first codfr where codfr.codfr = entry(i,spr_list) and codfr.code = string(v-who) no-lock no-error.
    if avail codfr then do:
        find first sysc where sysc.sysc = entry(i,spr_list) exclusive-lock no-error.
        if not avail sysc then do:
            create sysc.
            sysc.sysc = entry(i,spr_list).
            find first codific where codific.codfr = entry(i,spr_list) no-lock no-error.
            if avail codific then sysc.des = codific.Name.
        end.
        sysc.chval = codfr.name[1].
        find current sysc no-lock.
    end.
    else do:
        message " Не найден параметр (codfr) с кодом " + entry(i,spr_list) view-as alert-box error.
        err = err + 1.
    end.

end.

def var s-credtype as char no-undo init '6'. /* для pk-sysc.i */
{pk-sysc.i}

def var v-dcpath as char no-undo.
v-dcpath = get-pksysc-char ("dcpath").
if not v-dcpath begins "/" then v-dcpath = "/" + v-dcpath.
v-dcpath = g-dbdir + v-dcpath.

def var v-res as char no-undo.
def var v-f1 as char no-undo.
def var v-f2 as char no-undo.

v-f1 = v-dcpath + "pkdogsgn.jpg".
v-f2 = v-dcpath + "pkdogsgn" + string(v-who) + ".jpg".

input through value ("if [ -e " + v-f2 + " ]; then echo 1; else echo 0; fi").
import unformatted v-res.
if v-res = "1" then do:
    v-res = "0".
    input through value("rm -f " + v-f1 + "; cp -f " + v-f2 + " " + v-f1 + ";echo $?").
    import unformatted v-res.
    if v-res <> "0" then message " Произошла ошибка при замене файла подписи! " view-as alert-box error.
end.
else do:
    message " Не найден файл подписи для замены! " view-as alert-box error.
    err = err + 1.
end.

if err = 0 then do:
    find first sysc where sysc.sysc = "otvlico" exclusive-lock no-error.
    if avail sysc then sysc.chval = string(v-who).
    else do:
       create sysc .
       assign
           sysc.sysc = "otvlico"
           sysc.chval = string(v-who).
    end.

    message " Копирование произведено успешно! " view-as alert-box information.
end.

