/* pklondog.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Редактирование анкеты
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
        29/05/2006 madiyar
 * CHANGES
        24/08/2006 madiyar - редактирование номера гцвп-ответа
        20/09/2007 madiyar - добавил возможность повторной отправки запроса в ЦИС
        17/09/2008 madiyar - улица (недвижимость в собственности), берется из справочника, марка и модель авто - нет
        13/10/2008 madiyar - еще раз подправил работу со справочниками городов и улиц
        15/10/2008 madiyar - пример cvs
        29/11/2008 madiyar - повторный запрос в ГЦВП
        01/12/2008 madiyar - расширил фрейм
        18/09/2009 madiyar - съехало редактирование, поправил
*/

{global.i}
{pk.i}
{sysc.i}
{pk-sysc.i}

def new shared var v-cisres as char.
def new shared temp-table t-anket like pkanketh.

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
    message skip " Анкета N" s-pkankln "не найдена !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

function chkspr returns logical (input v-kritcod as char, input v-sprav as char, input v-code as char).
    def var v-res as logical.
    if v-sprav = '' or v-code = '' or s-ourbank <> "txb00" then return yes.
    if lookup(v-kritcod,"city1,street1,nedvstreet") > 0 then do:
      find first codfr where codfr.codfr = v-sprav and codfr.code = v-code no-lock no-error.
      v-res = avail codfr.
    end.
    else do:
      find first bookcod where bookcod.bookcod = v-sprav and bookcod.code = v-code no-lock no-error.
      v-res = avail bookcod.
    end.
    return v-res.
end.

def temp-table t-ln
  field code like codfr.code
  field name as char
  index main is primary code
  index sec name.

define query qt for pkkrit,pkanketh.
define buffer b-pkanketh for pkanketh.
def var v-rid as rowid.
def var v-spr as char no-undo.
def var v-name as char no-undo.
def var v-oldvalue as char no-undo.
def var choice as logical no-undo.
def stream out1.

define browse bt query qt
       displ pkkrit.kritname label "Критерий" format "x(31)"
             pkanketh.value1 label "Данные анкеты" format "x(34)"
             pkanketh.value2 label "Данные баз" format "x(34)"
             pkanketh.value3 label "Пр" format "x(1)"
       /* enable pkanketh.value1 pkanketh.value3 */
             with 33 down centered overlay no-label title " Редактирование анкеты ".

define frame ft bt help " <Enter>-Ред, <^G>-Номер ГЦВП, <^B>-ГЦВП, <^A>-ЦИС, F4-Выход" with width 110 row 1 overlay no-label no-box.

on value-changed of bt do:
  /* message "1111" view-as alert-box buttons ok. */
  find first pkkrit where pkkrit.kritcod = pkanketh.kritcod no-lock no-error.
end.

on "return" of bt in frame ft do:

   bt:set-repositioned-row(bt:focused-row, "conditional").
   v-rid = rowid(pkkrit).

   find first b-pkanketh where b-pkanketh.bank = pkanketh.bank and b-pkanketh.credtype = pkanketh.credtype and b-pkanketh.ln = pkanketh.ln and b-pkanketh.kritcod = pkanketh.kritcod exclusive-lock.
   displ b-pkanketh.value1 format "x(34)" b-pkanketh.value2 format "x(2000)" view-as fill-in size 34 by 1 b-pkanketh.value3 format "x(1)" with no-label overlay row bt:focused-row + 3 column 36 no-box frame fr2.
   v-oldvalue = b-pkanketh.value1.
   v-spr = ''.
   if pkkrit.kritspr ne '' then do:
     if num-entries(pkkrit.kritspr) = 1 then v-spr = pkkrit.kritspr.
     else v-spr = entry(integer(s-credtype),pkkrit.kritspr).
   end.

   on help of b-pkanketh.value1 in frame fr2 do:
     if v-spr <> '' then do:
       for each t-ln: delete t-ln. end.
       if lookup(pkkrit.kritcod,"city1,street1,nedvstreet") > 0 then do:
         for each codfr where codfr.codfr = v-spr no-lock:
             create t-ln.
             t-ln.code = codfr.code.
             t-ln.name = codfr.name[1].
         end.
       end.
       else
       for each bookcod where bookcod.bookcod = v-spr no-lock:
           create t-ln.
           t-ln.code = bookcod.code.
           t-ln.name = bookcod.name.
       end.
       find first t-ln no-error.
       if not avail t-ln then do:
         message skip " Справочник значений пуст! " skip(1) view-as alert-box button ok title "".
         return.
       end.
       if lookup(pkkrit.kritcod,"city1,street1,nedvstreet") > 0 then do:
       {itemlist.i
            &file = "t-ln"
            &frame = "row 6 centered scroll 1 12 down overlay "
            &where = " true "
            &flddisp = " t-ln.code label 'КОД' format 'x(9)'
                         t-ln.name label 'ЗНАЧЕНИЕ' format 'x(64)'
                        "
            &chkey = "code"
            &chtype = "string"
            &index  = "sec"
            &end = "if keyfunction(lastkey) = 'end-error' then return."
       }
       end.
       else do:
       {itemlist.i
            &file = "t-ln"
            &frame = "row 6 centered scroll 1 12 down overlay "
            &where = " true "
            &flddisp = " t-ln.code label 'КОД' format 'x(9)'
                         t-ln.name label 'ЗНАЧЕНИЕ' format 'x(64)'
                        "
            &chkey = "code"
            &chtype = "string"
            &index  = "main"
            &end = "if keyfunction(lastkey) = 'end-error' then return."
            &set = "1"
       }
       end.
       b-pkanketh.value1 = t-ln.code.
       displ b-pkanketh.value1 with frame fr2.
     end.
   end.

   update b-pkanketh.value1 validate (chkspr(pkkrit.kritcod,v-spr,b-pkanketh.value1)," Недопустимое значение! ") with frame fr2.
   if pkkrit.kritcod = "commentary" then update b-pkanketh.value2 with frame fr2.
   update b-pkanketh.value3 with frame fr2.
   hide frame fr2.
   b-pkanketh.value1 = trim(b-pkanketh.value1).

   if trim(v-oldvalue) <> b-pkanketh.value1 then do:
     if pkkrit.kritcod = "numpas" then do:
       find current pkanketa exclusive-lock.
       pkanketa.docnum = b-pkanketh.value1.
       find current pkanketa no-lock.
     end.
     if lookup(pkkrit.kritcod,"lname,fname,mname") > 0 then do:
       find first b-pkanketh where b-pkanketh.bank = s-ourbank and b-pkanketh.credtype = s-credtype and b-pkanketh.ln = s-pkankln and b-pkanketh.kritcod = "lname" no-lock no-error.
       if avail b-pkanketh then v-name = caps(trim(b-pkanketh.value1)).
       find first b-pkanketh where b-pkanketh.bank = s-ourbank and b-pkanketh.credtype = s-credtype and b-pkanketh.ln = s-pkankln and b-pkanketh.kritcod = "fname" no-lock no-error.
       if avail b-pkanketh then do:
         if v-name <> "" then v-name = v-name + " ".
         v-name = v-name + caps(trim(b-pkanketh.value1)).
       end.
       find first b-pkanketh where b-pkanketh.bank = s-ourbank and b-pkanketh.credtype = s-credtype and b-pkanketh.ln = s-pkankln and b-pkanketh.kritcod = "mname" no-lock no-error.
       if avail pkanketh then do:
         if v-name <> "" then v-name = v-name + " ".
         v-name = v-name + caps(trim(b-pkanketh.value1)).
       end.
       run pkdeffio (input-output v-name).
       find current pkanketa exclusive-lock.
       pkanketa.name = v-name.
       find current pkanketa no-lock.
     end.
     if pkkrit.kritcod = "sik" then do:
       find current pkanketa exclusive-lock.
       pkanketa.sik = b-pkanketh.value1.
       find current pkanketa no-lock.
     end.
   end.

   open query qt for each pkkrit where pkkrit.priz = "1" and lookup (s-credtype, pkkrit.credtype) > 0 use-index kritcod no-lock, each pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = pkkrit.kritcod no-lock.

   reposition qt to rowid v-rid no-error.
   bt:refresh().

end. /* on "return" of bt */

/* Ctrl+G - привязка нового запроса ГЦВП */
on "editor-tab" of bt in frame ft do:

    find first b-pkanketh where b-pkanketh.bank = s-ourbank and b-pkanketh.credtype = s-credtype and b-pkanketh.ln = s-pkankln and b-pkanketh.kritcod = 'sik' exclusive-lock no-error.
    if not avail b-pkanketh then message " Не найден критерий СИК! " view-as alert-box error.
    else do:
        update skip(1) b-pkanketh.rescha[3] format "x(25)" label " N ответа ГЦВП" skip(1) with centered row 9 side-labels overlay title "gcvp-edit" frame gcvpfr.
        find current b-pkanketh no-lock.
    end.

end. /* on "editor-tab" of bt */

/* Ctrl+A - повторный запрос в ЦИС */
on "append-line" of bt in frame ft do:

    choice = no.
    message "Отправить повторно запрос в ЦИС?" view-as alert-box question buttons ok-cancel title "" update choice.
    if choice then do:
        for each b-pkanketh where b-pkanketh.bank = s-ourbank and b-pkanketh.credtype = s-credtype and b-pkanketh.ln = s-pkankln no-lock:
            create t-anket.
            buffer-copy b-pkanketh to t-anket.
        end.
        run pkcisout.
        do transaction:
            find first b-pkanketh where b-pkanketh.bank = s-ourbank and b-pkanketh.credtype = s-credtype and b-pkanketh.ln = s-pkankln and b-pkanketh.kritcod = "akires" exclusive-lock.
            b-pkanketh.value1 = "".
            b-pkanketh.value2 = v-cisres.
            b-pkanketh.value3 = "1".
            b-pkanketh.value4 = "1".
        end.
    end.

end.

/* Ctrl+B - повторный запрос в ГЦВП */
on "editor-backtab" of bt in frame ft do:

    choice = no.
    message "Отправить повторно запрос в ГЦВП?" view-as alert-box question buttons ok-cancel title "" update choice.
    if choice then do transaction:

        def var p-sik as char.
        def var p-lastname as char.
        def var p-firstname as char.
        def var p-midname as char.
        def var p-plastname as char.
        def var p-birthdt as char.
        def var p-numpas as char.
        def var p-dtpas as char.
        def var v-file as char.
        def var v-date as char.
        def var v-sr as char.
        def var v-dirq as char.
        def var num as int.

        find first sysc where sysc.sysc = "PKGCVY" no-lock no-error.
        if not avail sysc or not sysc.loval then do:
            message skip " Запрос данных в ГЦВП в данный момент не работает !" skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
        end.
        else do:
            num = next-value(pk-gcvp).
            v-sr = string(get-pksysc-int ("gcvpsr")).
            v-date = substr(string(g-today), 1, 6) + string(year(g-today)).
            v-dirq = get-sysc-cha ("pkgcvq").
            v-file = fill("0", 8 - length(trim(string(num)))) + trim(string(num)).

            find first b-pkanketh where b-pkanketh.bank = s-ourbank and b-pkanketh.credtype = s-credtype and b-pkanketh.ln = s-pkankln and b-pkanketh.kritcod = "sik" no-error.
            if not avail b-pkanketh then do:
                message "Ошибка! Не найден критерий СИК" view-as alert-box error.
                undo,leave.
            end.
            else do:
                p-sik = caps(trim(b-pkanketh.value1)).
                find first b-pkanketh where b-pkanketh.bank = s-ourbank and b-pkanketh.credtype = s-credtype and b-pkanketh.ln = s-pkankln and b-pkanketh.kritcod = "pname" no-lock no-error.
                if avail b-pkanketh and trim(b-pkanketh.value1) <> "" then do:
                    p-lastname = caps(trim(b-pkanketh.value1)).

                    /* выяснилось, что в документе СИКа могут быть указаны и прежние, и новые данные - тогда они через слэш
                       и ГЦВП проверяет по ПЕРВОМУ значению, то есть по текущей фамилии!
                       для отслеживания этого факта служит критерий ciktwo :  если = 1, то посылать текущие данные, нет - старые
                    */
                    find first b-pkanketh where b-pkanketh.bank = s-ourbank and b-pkanketh.credtype = s-credtype and b-pkanketh.ln = s-pkankln and b-pkanketh.kritcod = "siktwo" no-error.
                    if avail b-pkanketh and trim(b-pkanketh.value1) <> "" and integer(trim(b-pkanketh.value1)) = 1 then do:
                        find first b-pkanketh where b-pkanketh.bank = s-ourbank and b-pkanketh.credtype = s-credtype and b-pkanketh.ln = s-pkankln and b-pkanketh.kritcod = "lname" no-error.
                        p-lastname = caps(trim(b-pkanketh.value1)).
                    end.
                end.
                else do:
                    find first b-pkanketh where b-pkanketh.bank = s-ourbank and b-pkanketh.credtype = s-credtype and b-pkanketh.ln = s-pkankln and b-pkanketh.kritcod = "lname" no-error.
                    p-lastname = caps(trim(b-pkanketh.value1)).
                end.

                find first b-pkanketh where b-pkanketh.bank = s-ourbank and b-pkanketh.credtype = s-credtype and b-pkanketh.ln = s-pkankln and b-pkanketh.kritcod = "fname" no-error.
                if avail b-pkanketh then p-firstname = caps(trim(b-pkanketh.value1)).

                find first b-pkanketh where b-pkanketh.bank = s-ourbank and b-pkanketh.credtype = s-credtype and b-pkanketh.ln = s-pkankln and b-pkanketh.kritcod = "mname" no-error.
                if avail b-pkanketh then p-midname = caps(trim(b-pkanketh.value1)).

                find first b-pkanketh where b-pkanketh.bank = s-ourbank and b-pkanketh.credtype = s-credtype and b-pkanketh.ln = s-pkankln and b-pkanketh.kritcod = "bdt" no-error.
                if avail b-pkanketh then p-birthdt = string(date(b-pkanketh.value1), "99/99/9999").

                find first b-pkanketh where b-pkanketh.bank = s-ourbank and b-pkanketh.credtype = s-credtype and b-pkanketh.ln = s-pkankln and b-pkanketh.kritcod = "numpas" no-lock no-error.
                if avail b-pkanketh then p-numpas = caps(trim(b-pkanketh.value1)).

                find first b-pkanketh where b-pkanketh.bank = s-ourbank and b-pkanketh.credtype = s-credtype and b-pkanketh.ln = s-pkankln and b-pkanketh.kritcod = "dtpas" no-lock no-error.
                if avail b-pkanketh then p-dtpas = string(date(b-pkanketh.value1), "99/99/9999").

                output stream out1 to rpt.txt.
                put stream out1 unformatted  v-file + "|" +  v-date + "|2|" + p-sik + "|" + p-lastname + "|" +
                                             p-firstname + "|" + p-midname + "|" + p-birthdt +  "|" + v-file + "|" +
                                             v-date + "|" skip.

                output stream out1 close.
                unix silent un-win rpt.txt value(v-file).
                unix silent cp value(v-file) value(v-dirq + v-file).

                find sysc where sysc.sysc = "pkgcvm" no-lock no-error.

                run mail(trim(sysc.chval), "MKO NK <abpk@metrobank.kz>","Fdjkl358Jd", "" , "1", "", v-file).

                run savelog( "gcvpout", "Отправка файла в ГЦВП : " + v-file).

                find first b-pkanketh where b-pkanketh.bank = s-ourbank and b-pkanketh.credtype = s-credtype and b-pkanketh.ln = s-pkankln and b-pkanketh.kritcod = "sik" no-error.
                b-pkanketh.rescha[3] = "metrocombank" + v-file.

                unix silent cp value(v-file) value(v-dirq + v-file).
                unix silent rm -f value(v-file).

                create gcvp.
                assign gcvp.bank = s-ourbank
                       gcvp.lname = p-lastname
                       gcvp.fname = p-firstname
                       gcvp.mname = p-midname
                       gcvp.dtb = date(p-birthdt)
                       gcvp.sik = p-sik
                       gcvp.ofc = g-ofc
                       gcvp.rdt = g-today
                       gcvp.nfile = v-file.
                release gcvp.

                message skip "Запрос ї " + v-file + " отправлен в ГЦВП " skip(1) view-as alert-box button Ok title "Внимание!".
            end.
        end.
    end.
end.

open query qt for each pkkrit where pkkrit.priz = "1" and lookup (s-credtype, pkkrit.credtype) > 0 use-index kritcod no-lock, each pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = pkkrit.kritcod no-lock.
enable bt with frame ft.
apply "value-changed" to browse bt.

wait-for window-close of current-window.
pause 0.
