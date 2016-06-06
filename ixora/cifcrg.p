/* cifcrgh.p
 * MODULE
        Клиенты и их счета
 * DESCRIPTION
        История изменения статуса контроля признаков клиента
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        s-cifchk.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.11
 * AUTHOR
        04.11.03 sasco
 * CHANGES
        14.05.04 dpuchkov добавил ограничение контроля для менеджеров работающих в воскресенье.
        31.05.04 dpuchkov огранич. контроля только для счетов клиентов открытых этим менеджером.
        17.08.04 sasco    менеджер не может контролировать себя
        25/03/2010 galina - проверяем заполненность данных для фин.мониторинга
        13/04/2010 galina - не проверяем наличие РНН у нерезидента
        13.04.2011 damir - после проставления контроля присвается стс yes в таблице aaaperost
        28.08.2012 id00810 - связь с таблицей pcstaff0 по платежным карточкам
        11.09.2012 id00810 - исправлена ошибка в смене статуса в табл.pcstaff0
        07.11.2012 evseev - ИИН/БИН
        11.03.2013 Lyubov - ТЗ №1742, для контроля ПК добавляем вывод полей код.слово и фамилия/имя лат. буквами
        30.03.2013 Lyubov - ТЗ №1772, при снятии отметки о контр. статус меняется на "ааа"
        31.05.2013 Lyubov - ТЗ №1865, связка с таблицей pcstaff0 осуществляется по cif-коду
        02.07.2013 Lyubov - ТЗ №1939, обработка записей со статусом <> Closed
        21.10.2013 Lyubov - ТЗ №1900, изменения отражаюся в pcstaff0
        24/10/2012 galina - ТЗ 2159 отражаем изменения в pcstaff0 только если cif.bin <> ''
        29.10.2013 Lyubov - ТЗ №2158, добавлены ID и статус в текст письма, письма отправляюься только по статусам OK, Decline
        29.11.2013 Lyubov - ТЗ №2209, контроль VIP клиентам только по пакетам p00121, p00082
*/


define shared variable s-cif like cif.cif.
define shared variable g-ofc as character.
define shared variable g-today as date.

define variable v-mess as character.
define variable v-ans as logical.
define variable v-friday as logical.

def var v-pss as char format "x(9)".
def var v-issuredby as char format "x(9)".
def var v-pssdt  as date format "99/99/9999".
def var v-str as character.

{chbin.i}
v-friday = False.

find cif where cif.cif = s-cif no-lock no-error.
if not available cif then return.

if cif.who = g-ofc then do:
    message "Вы не можете акцептовать клиента, которого сами отредактировали!" view-as alert-box.
    return.
end.

find first pcstaff0 where pcstaff0.cif = cif.cif and pcstaff0.sts <> 'Closed' no-lock no-error.
if avail pcstaff0 then do:
    form pcstaff0.namelat format 'x(30)' label 'Фамилия/имя(лат.)' pcstaff0.cword   format 'x(15)' label 'Кодовое слово' with width 50 row 25 1 down frame fdop.
    displ pcstaff0.namelat pcstaff0.cword with frame fdop.
end.

find ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then do:
    if today - g-today = 0 then do: /* если не сб и вс */
        if ofc.oday[5] = 1 then do:
            MESSAGE "Для данного менеджера действует ограничение контроля !" VIEW-AS ALERT-BOX .
            return.
        end.
    end.
    else do: /* если выходной и опердень пятница */
        if ofc.oday[5] = 1 then do:
            find first aaa where aaa.cif = s-cif and aaa.who = g-ofc  no-lock no-error.
            if not avail aaa then do:
                MESSAGE "Вы не можете контролировать счета открытые другими менеджерами!" VIEW-AS ALERT-BOX .
                return.
            end.
        end.
    end.
    if cif.mname = 'VIP' then do:
        if not can-do(ofc.expr[1],'p00121') and not can-do(ofc.expr[1],'p00082') then do:
            message 'У вас нет прав для проставления контроля VIP-клиенту!' view-as alert-box.
            return.
        end.
    end.
end.
/*проверка полноты заполнения даннаых для фин.мониторинга*/
if cif.crg = "" then do:
    if cif.geo = '021' and trim(cif.bin) = "" then do:
        message "Не введен ИИН/БИН клиента!" view-as alert-box title "ВНИМАНИЕ".
        return.
    end.
    if trim(cif.addr[1]) = "" then do:
        message "Не введен юридический адрес клиента!" view-as alert-box title "ВНИМАНИЕ".
        return.
    end.
    if trim(cif.addr[2]) = "" then do:
        message "Не введен фактический адрес клиента!" view-as alert-box title "ВНИМАНИЕ".
        return.
    end.
    if trim(cif.reschar[1]) = "" then do:
        message "Клиент не заполнил анкету для фин.мониторинга или менеджер не проставил дату заполнения" view-as alert-box title "ВНИМАНИЕ".
        return.
    end.
    if cif.type <> "B" then do:
        find sub-cod where sub-cod.sub = "cln" and sub-cod.acc = s-cif and sub-cod.d-cod = "publicf" and sub-cod.ccode <> "msc" no-lock no-error.
        if not avail sub-cod then do:
            message "Не проставлен признак publicf у клиента!" view-as alert-box title "ВНИМАНИЕ".
            return.
        end.
    end.
end.
/**/

if cif.crg = "" then v-mess = "Установить".
                else v-mess = "Снять".
v-ans = no.

message v-mess + " отметку о контроле? Вы уверены?" update v-ans.

if v-ans then do:
  create crg.

  crg.crg = string(next-value(crgnum)).
  crg.des = cif.cif.
  crg.who = g-ofc.
  crg.whn = g-today.

  if cif.crg = "" then assign crg.stn = 1
                              cif.crg = crg.crg.
                  else assign crg.stn = 0
                              cif.crg = "".

  crg.tim = time.
  crg.regdt = today.

    if cif.crg <> "" then do: /*damir*/
        find last aaaperost where aaaperost.cif = s-cif and aaaperost.whn = g-today exclusive-lock no-error.
        if avail aaaperost then do:
            aaaperost.sts = yes.
        end.
        find last aaaperost where aaaperost.cif = s-cif and aaaperost.whn = g-today no-lock no-error.
    end.
    if trim(cif.bin) <> '' then do:
        find first pcstaff0 where pcstaff0.iin = cif.bin and pcstaff0.sts <> 'Closed' no-lock no-error.
        if avail pcstaff0 then do:
            find current pcstaff0 exclusive-lock.
            if pcstaff0.sts = 'ready' and cif.crg = '' then pcstaff0.sts = 'aaa'.
            if pcstaff0.sts = 'aaa'   and cif.crg ne '' then pcstaff0.sts = 'ready'.

            if can-do('OK,Decline',pcstaff0.sts) and cif.crg ne '' then do:
                case num-entries(trim(cif.pss),' '):
                    when 1 then v-pss = cif.pss.
                    when 2 then do: v-pss = entry(1,cif.pss, ' ').
                                    v-pssdt = date(entry(2,cif.pss, ' ')) no-error.
                    end.
                    when 3 then do: v-pss = entry(1,cif.pss, ' ').
                                    v-pssdt = date(entry(2,cif.pss, ' ')) no-error.
                                    v-issuredby = entry(3,cif.pss, ' ').
                    end.
                    when 4 then do: v-pss = entry(1,cif.pss, ' ').
                                    v-pssdt = date(entry(2,cif.pss, ' ')) no-error.
                                    v-issuredby = entry(3,cif.pss, ' ') + ' ' +  entry(4,cif.pss, ' ').
                    end.
                end.

                if pcstaff0.sname <> cif.famil or pcstaff0.fname <> cif.imya or pcstaff0.mname <> cif.otches or pcstaff0.expdt <> cif.dtsrokul
                or nomdoc <> v-pss or issdt <> v-pssdt or issdoc <> v-issuredby or (pcstaff0.addr[1] <> cif.addr[1] and cif.addr[1] <> '')
                or (pcstaff0.addr[2] <> cif.addr[2] and cif.addr[2] <> '') or (pcstaff0.tel[1] <> cif.tel and cif.tel <> '')
                or (pcstaff0.tel[2] <> cif.fax and cif.fax <> '') then do:

                    v-str = "Необходимо произвести изменения в системе OW. "
                    + pcstaff0.aaa + ' ' + cif.famil + ' ' + cif.imya + ' ' + cif.otches + ":\n".

                    if pcstaff0.nomdoc  <> v-pss        then v-str = v-str + "Номер документа "   + v-pss + "\n".
                    if pcstaff0.issdoc  <> v-issuredby  then v-str = v-str + "Кем выдан "         + v-issuredby + "\n".
                    if pcstaff0.issdt   <> v-pssdt      then v-str = v-str + "Когда выдан "       + string(v-pssdt) + "\n".
                    if pcstaff0.expdt   <> cif.dtsrokul then v-str = v-str + "Срок действия "     + string(cif.dtsrokul) + "\n".
                    if pcstaff0.addr[1] <> cif.addr[1] and cif.addr[1] <> '' then v-str = v-str + "Юридический адрес " + cif.addr[1] + "\n".
                    if pcstaff0.addr[2] <> cif.addr[2] and cif.addr[2] <> '' then v-str = v-str + "Фактический адрес " + cif.addr[2] + "\n".
                    if pcstaff0.tel[1]  <> cif.tel     and cif.tel     <> '' then v-str = v-str + "Телефон общий "     + cif.tel + "\n".
                    if pcstaff0.tel[2]  <> cif.fax     and cif.fax     <> '' then v-str = v-str + "Телефон мобильный " + cif.fax + "\n".

                    v-str = v-str + "Статус счета " + pcstaff0.sts + "\n".
                    v-str = v-str + "Правил " + cif.who + "\n".

                    assign pcstaff0.sname   = cif.famil
                           pcstaff0.fname   = cif.imya
                           pcstaff0.mname   = cif.otches
                           pcstaff0.nomdoc  = v-pss
                           pcstaff0.issdt   = v-pssdt
                           pcstaff0.issdoc  = v-issuredby
                           pcstaff0.expdt   = cif.dtsrokul.
                           if cif.addr[1] <> '' then pcstaff0.addr[1] = cif.addr[1].
                           if cif.addr[2] <> '' then pcstaff0.addr[2] = cif.addr[2].
                           if cif.tel <> ''     then pcstaff0.tel[1] = cif.tel.
                           if cif.fax <> ''     then pcstaff0.tel[2] = cif.fax.

                    run mail("DPC@fortebank.com","FORTEBANK <abpk@fortebank.com>","Изменение данных ОО в 1-1-2",v-str, "", "","").

                end.
            end.
            find current pcstaff0 no-lock.
        end.
    end.

end.