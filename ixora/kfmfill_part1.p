/* kfmfill_part1.p
 * MODULE
        Финансовый мониторинг
 * DESCRIPTION
        Вывод формы ФМ-1 менеджеру для заполнения
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
        30/03/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
        31.03.2010 galina - явно указала ширину фрейма xf
        05/05/2010 galina - добавила возможность выбора довер.лица
*/

{global.i}

{kfm.i}
{kfmValid.i}

def input parameter p-operId as integer no-undo.
def input parameter p-partId as integer no-undo.

define query q_prth for t-kfmprth.
def var v-rid as rowid.
def new shared var s-cif as char.

def buffer bt-kfmprth for t-kfmprth.

define browse b_prth query q_prth
       displ t-kfmprth.dataName label "Поле" format "x(32)"
             t-kfmprth.dataValueVis label "Значение" format "x(70)"
             with 29 down overlay no-label title " Данные по участнику операции ".

define frame f_prth b_prth help "<Enter>-Редакт. <F4>-Возврат к участникам" with width 110 row 3 /*overlay*/ no-box.

{adres.f}

def var v-errMsg as char no-undo init "Введено некорректное значение или значение отсутствует в справочнике!".

define frame f2_prth
    t-kfmprth.dataName format "x(32)"
    t-kfmprth.dataValue format "x(70)" validate(validh(t-kfmprth.dataCode,t-kfmprth.dataValue, output v-errMsg),v-errMsg)
    with width 104 no-label overlay column 4 no-box.

def var v-aaa as char.
def var v-uplname as char.
def var v-uplid as integer.
def var v-res as char.
def var v-res2 as char.
def var v-prtFLNam as char.
def var v-prtFFNam as char.
def var v-prtFMNam as char.
def var v-num as integer.
def var choice as logi.
def buffer bt-kfmprt for t-kfmprt.

on "enter" of b_prth in frame f_prth do:
    if avail t-kfmprth then do:
        /*
        b_prth:set-repositioned-row(b_prth:focused-row, "always").
        v-rid = rowid(t-kfmprth).
        */

        case t-kfmprth.dataCode:
            when "prtAddrU" or when "prtAddrF" then do:
                v-adres = t-kfmprth.dataValue.
                assign v-country2 = ''
                       v-region = ''
                       v-city = ''
                       v-street = ''
                       v-house = ''
                       v-office = ''
                       v-index = ''
                       v-title = t-kfmprth.dataName.
                {adres.i}
                t-kfmprth.dataValue = v-adres.
            end.
            when "prtFounU" then do:
                s-cif = ''.
                find first bt-kfmprth where bt-kfmprth.bank = s-ourbank and bt-kfmprth.operId = p-operId and bt-kfmprth.partId = p-partId and bt-kfmprth.dataCode = "prtBAcc" no-lock no-error.
                if avail bt-kfmprth and bt-kfmprth.dataValue <> '' then do:
                    find first aaa where aaa.aaa = bt-kfmprth.dataValue no-lock no-error.
                    if avail aaa then s-cif = aaa.cif.
                    else do:
                        find first arp where arp.arp = bt-kfmprth.dataValue no-lock no-error.
                        if avail arp then s-cif = arp.cif.
                    end.
                end.
                if s-cif = '' then message "Не найден клиент для определения учредителей.~nПроверьте правильность заполнения номера счета участника." view-as alert-box error.
                else do:
                    frame f_prth:visible = no.
                    run founder.
                    frame f_prth:visible = yes.
                end.
            end.
            when "prtFrom" then do:
                find first bt-kfmprth where bt-kfmprth.bank = s-ourbank and bt-kfmprth.operId = p-operId and bt-kfmprth.partId = p-partId and bt-kfmprth.dataCode = "prtWhat" no-lock no-error.
                if avail bt-kfmprth and (bt-kfmprth.dataValue = '02' or bt-kfmprth.dataValue = '03') then do:
                    frame f2_prth:row = b_prth:focused-row + 5.
                    displ t-kfmprth.dataName t-kfmprth.dataValue with frame f2_prth.
                    update t-kfmprth.dataValue with frame f2_prth.
                    if v-uplname = trim(t-kfmprth.dataValue) then do:
                        message "Будет создан еще один участник операции " + v-uplname + "~nПродолжить?" view-as alert-box question buttons yes-no update choice.
                        if choice then do:
                          find first upl where upl.uplid = v-uplid no-lock no-error.
                          if avail upl then do:

                              v-res = substr(entry(2,entry(1,upl.uradr),'('),1,2).
                              if v-res = 'kz' then v-res2 = '1'.
                              else v-res2 = '0'.
                              if num-entries(v-uplname,' ') > 0 then v-prtFLNam = entry(1,v-uplname,' ').
                              if num-entries(v-uplname,' ') > 1 then v-prtFFNam = entry(2,v-uplname,' ').
                              if num-entries(v-uplname,' ') > 2 then v-prtFMNam = entry(3,v-uplname,' ').

                              v-num = 0.
                              find last bt-kfmprt where bt-kfmprt.bank = s-ourbank and bt-kfmprt.operId = p-operId no-lock no-error.
                              if avail bt-kfmprt then v-num = bt-kfmprt.partId + 1.
                              else v-num = v-num + 1.
                              run kfmprt_cre(p-operId,v-num,'01','02','05',v-res2,v-res,'02','','','','','','','','','','','','','','','','',v-prtFLNam,v-prtFFNam,v-prtFMNam,'','','01',upl.dok1,'',upl.docreg,string(upl.docdt,'99/99/9999'),upl.bdt,upl.bplace,upl.uradr,'','').

                              for each bt-kfmprth where bt-kfmprth.bank = s-ourbank and bt-kfmprth.operId = p-operId and bt-kfmprth.partId = v-num :
                                 bt-kfmprth.dataValueVis = getVisual(bt-kfmprth.dataCode,bt-kfmprth.dataValue).
                              end.

                          end.
                        end.
                    end.
                end.
            end.
            otherwise do:
                frame f2_prth:row = b_prth:focused-row + 5.
                displ t-kfmprth.dataName t-kfmprth.dataValue with frame f2_prth.
                update t-kfmprth.dataValue with frame f2_prth.
            end.
        end case.

        t-kfmprth.dataValueVis = getVisual(t-kfmprth.dataCode, t-kfmprth.dataValue).
        b_prth:refresh().
    end.
end.

on help of t-kfmprth.dataValue in frame f2_prth do:
    case t-kfmprth.dataCode:
       when "prtFrom" then do:
            s-cif = ''.
            v-aaa = ''.
            v-uplname = ''.
            find first bt-kfmprth where bt-kfmprth.bank = s-ourbank and bt-kfmprth.operId = p-operId and bt-kfmprth.partId = p-partId and bt-kfmprth.dataCode = "prtBAcc" no-lock no-error.
            if avail bt-kfmprth and bt-kfmprth.dataValue <> '' then do:
                find first aaa where aaa.aaa = bt-kfmprth.dataValue no-lock no-error.
                if avail aaa then do:
                    s-cif = aaa.cif.
                    v-aaa = aaa.aaa.
                end.
                else do:
                    find first arp where arp.arp = bt-kfmprth.dataValue no-lock no-error.
                    if avail arp then do:
                        s-cif = arp.cif.
                        v-aaa = arp.arp.
                    end.
                end.
            end.
            if s-cif <> '' then find first cif where cif.cif = s-cif no-lock no-error.
            if s-cif = '' or not avail cif then message "Не найден клиент для определения доверенных лиц.~nПроверьте правильность заполнения номера счета участника." view-as alert-box error.
            find first uplcif where uplcif.cif = s-cif and uplcif.dop = v-aaa and uplcif.coregdt <= g-today and uplcif.finday >= g-today no-lock no-error.
            if avail uplcif then do:

                {itemlist.i
                 &set = "upl"
                 &file = "uplcif"
                 &frame = "row 6 centered scroll 1 20 down overlay width 100 "
                 &where = " uplcif.cif = s-cif and uplcif.dop = v-aaa and uplcif.coregdt <= g-today and uplcif.finday >= g-today "
                 &index  = "uplcif"
                 &flddisp = " uplcif.badd[1] label 'ФИО' format 'x(40)'
                              uplcif.dop label 'Счет' format 'x(20)'
                              uplcif.coregdt label 'Дата рег.' format '99/99/99'
                              uplcif.finday  label 'Дата окон.' format '99/99/99'
                              uplcif.badd[2] label 'Пасп/удов N' format 'x(15)' "
                 &chkey = "badd[1]"
                 &end = "if keyfunction(lastkey) = 'end-error' then return."
                 }

                 t-kfmprth.dataValue = uplcif.badd[1].
                 v-uplname = uplcif.badd[1].
                 v-uplid = uplcif.uplid.
                 displ t-kfmprth.dataValue with frame f2_prth.
                 /*сюда добавить создание запись по дов.лицу?*/
            end.
       end.
       otherwise do:
            find first kfmkrit where kfmkrit.dataCode = t-kfmprth.dataCode no-lock no-error.
            if avail kfmkrit and trim(kfmkrit.dataSpr) <> '' then do:
                find first codfr where codfr.codfr = trim(kfmkrit.dataSpr) no-lock no-error.
                if avail codfr then do:
                    {itemlist.i
                        &file = "codfr"
                        &frame = "row 6 centered scroll 1 20 down overlay width 91 "
                        &where = " codfr.codfr = trim(kfmkrit.dataSpr) "
                        &flddisp = " codfr.code label 'Код' format 'x(8)' codfr.name[1] label 'Значение' format 'x(80)' "
                        &chkey = "code"
                        &index  = "cdco_idx"
                        &end = "if keyfunction(lastkey) = 'end-error' then return."
                    }
                    t-kfmprth.dataValue = codfr.code.
                    displ t-kfmprth.dataValue with frame f2_prth.
                end.
            end.
       end.
    end case.
end.

open query q_prth for each t-kfmprth where t-kfmprth.bank = s-ourbank and t-kfmprth.operId = p-operId and t-kfmprth.partId = p-partId no-lock use-index idx_sort.
enable all with frame f_prth.

wait-for window-close of current-window in frame f_prth.




