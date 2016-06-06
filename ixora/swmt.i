/* swmt.i
 * MODULE
        Название Программного Модуля
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
        31/12/99 pragma
 * CHANGES
        29/03/05 sasco Добавил принудительный update swout.mt = swmt для 202
        10.05.2010 k.gitalov добавил функцию SetContent,
                             изменил заполнение 71 поля в PROCEDURE UPDT-ROW.
        24.05.2011 aigul - исправила сохраниение страны для sub-cod.acc = s-remtrz and sub-cod.sub = 'rmz' and sub-cod.d-cod = 'iso3166'
        27.09.2012 evseev - логирование

*/

/*** KOVAL Ввод свифтовых макетов ***/

{comm-cfr.i}

/* Процедуры */

def var b33 as deci.
def var tstr as char.

function SetContent returns log (input Level as int , input NM as char ,input sType as char, input Content as char):
   def buffer b-swin for swin.
   find first b-swin where b-swin.swfield = NM and b-swin.type = sType exclusive-lock no-error.
   if avail b-swin then do:
       b-swin.content[Level] = Content.
       apply "value-changed" to self.
       return true.
   end. else return false.
end function.

/* sasco : buffer */
define buffer b-swin for swin.

PROCEDURE UPDT-ROW.
     def var distype as log init true.
     def var discon2 as log init true.
     def var discon3 as log init true.
     def var discon4 as log init true.
     def var discon5 as log init true.
     def var discon6 as log init true.

     def var f_crc as char format "x(3)" label "Валюта".
     def var f_amt as decimal format ">,>>>,>>>,>>>,>>9.99" label "Сумма" init 0.
     def frame f_frame
         f_crc validate(f_crc<>"" or (swmt='103' and (swin.swfield='33' or swin.swfield='71')),"Заполните поле валюты !")
         f_amt  validate(f_amt>0 or (swmt='103' and (swin.swfield='33' or swin.swfield='71')),"Заполните сумму !")
         with centered title "Введите значение поля " + swin.swfield + swin.type.

     on help of f_crc in frame f_frame do:
        run comm-cfr("crcname", input-output f_crc).        /* Передаем код справочник и input-output переменную */
     end.

     /* Вычислим нередактируемые поля */
     if lookup(swin.swfield, swlist.nonedit)>0 then return.

     /* Вывод */
     if swin.type="" then do:
        case swin.swfield:
            when "21" then assign discon2=false discon3=false discon4=false discon5=false discon6=false .
            when "59" then assign discon6=false.
            when "50" or when "70" then assign discon5=false discon6=false .
        end case.
     end.

     if index(remtrz.sqn, "IBH") = 0 and remtrz.source <> "IBH" then do:
         if swin.swfield = "33" then do:
            disable swin.type swin.content with frame ord-info.
            result = true.
            f_crc = entry (1, swin.content[1], ' ').
            if num-entries (swin.content[1], ' ') > 1 then f_amt = decimal(entry(2, swin.content[1], ' ')) no-error.
            update f_crc f_amt with frame f_frame.
            if trim (f_crc) = '' then assign swin.content[1] = ''.
                                 else assign swin.content[1] = caps(f_crc) + " " + trim(string(f_amt,">>>>>>>>>>>>>>9.99")).
            disp swin.content with frame ord-info.
            return.
         end.
     end. else do:
         if swin.swfield = "33" then do:
            disable swin.type swin.content with frame ord-info.
            result = true.
            f_crc = substr(swin.content[1], 1,3).
            f_amt = decimal(replace(substr(swin.content[1],4),',','.')) no-error.
            update f_crc f_amt with frame f_frame.
            if trim (f_crc) = '' then assign swin.content[1] = ''.
                                 else assign swin.content[1] = caps(f_crc) + "" + replace(trim(string(f_amt,">>>>>>>>>>>>>>9.99")),".",",").
            disp swin.content with frame ord-info.
            return.
         end.
     end.

     if swin.swfield = "71" then do:
        disable swin.type swin.content with frame ord-info.
        result = true.
        if swin.type="A" then do:
            if swmt='103' then run sel("Выберите значение","BEN|OUR|SHA"). else run sel("Выберите значение","BEN|OUR").
            case return-value:
                when '1' then do:
                     swin.content[1] = "BEN".
                     if remtrz.tcrc = remtrz.svcrc then do: /* Валюта платежа равна валюте комиссии*/
                        b33 = remtrz.svca + remtrz.payment.
                        tstr = string(remtrz.svca, ">>>>>>>>>>>>9.99").
                        tstr = replace(tstr, ".", ",").
                        find first crc where crc.crc = remtrz.tcrc no-lock no-error.
                        tstr = crc.code + " " + tstr.
                        SetContent(1,"71","F",tstr).
                        tstr = string(b33, ">>>>>>>>>>>>9.99").
                        tstr = replace(tstr, ".", ",").
                        tstr = crc.code + " " + tstr.
                        SetContent(1,"33","B",tstr).
                     end. else do:
                        if remtrz.svcrc <> 1 then do: message "Валюта комиссии не тенге!" view-as alert-box. end.
                        else do: /*Комиссия в тенге*/
                           find first crc where crc.crc = remtrz.tcrc no-lock no-error.
                           b33 = remtrz.svca / crc.rate[1].
                           b33 = round(round(b33,3),2).
                           tstr = string(b33, ">>>>>>>>>>>>9.99").
                           tstr = crc.code + " " + tstr.
                           SetContent(1,"71","F",tstr).
                           b33 = b33 + remtrz.payment.
                           tstr = string(b33, ">>>>>>>>>>>>9.99").
                           tstr = replace(tstr, ".", ",").
                           tstr = crc.code + " " + tstr.
                           SetContent(1,"33","B",tstr).
                        end.
                     end.
                end.
                when '2' then do:
                  swin.content[1] = "OUR".
                  SetContent(1,"71","F","").
                  SetContent(1,"33","B","").
                end.
                when '3' then do:
                   swin.content[1] = "SHA".
                   SetContent(1,"71","F","").
                   SetContent(1,"33","B","").
                end.
                otherwise assign result = false err = 'Недопустимое значение поля 71: '.
            end case.
        end.
        if index(remtrz.sqn, "IBH") = 0 and remtrz.source <> "IBH" then do:
            if swin.type="F" then do:
                f_crc = entry (1, swin.content[1], ' ').
                if num-entries (swin.content[1], ' ') > 1 then f_amt = decimal(entry(2, swin.content[1], ' ')) no-error.
                update f_crc f_amt with frame f_frame.
                if trim (f_crc) = '' then assign swin.content[1] = ''.
                                     else assign swin.content[1] = caps(f_crc) + " " + trim(string(f_amt,">>>>>>>>>>>>>>9.99")).
            end.
        end. else do:
            if swin.type="F" then do:
                f_crc = substr(swin.content[1], 1,3).
                f_amt = decimal(replace(substr(swin.content[1],4),',','.')) no-error.
                update f_crc f_amt with frame f_frame.
                if trim (f_crc) = '' then assign swin.content[1] = ''.
                                     else assign swin.content[1] = caps(f_crc) + "" + replace(trim(string(f_amt,">>>>>>>>>>>>>>9.99")),".",",").
            end.
        end.
        disp swin.content with frame ord-info.
        return.
     end.

     if swin.swfield = "9f" then do:
        /* Выбираем справочник стран */
        if country = ? then country = substr(destination, 5, 2).
        run comm-cfr("iso3166", input-output country).                         /* Передаем код справочник и input-output переменную */
        if return-value <> ? then do:
           assign swin.content[1] = country swin.content[2]=return-value.
           swin.content[1]:screen-value = country.
           swin.content[2]:screen-value = return-value.
        end.
        disp swin.content with frame ord-info.
        return.
     end.

     /* Проверим есть ли у этого поля разные типы */
     if lookup(swin.swfield,swlist.distype) > 0 then distype = false. else distype = true.

     {swmt-i-t.i}

     /* Вообщем, самый главный апдейт */
     run savelog("swiftmaket", "swmt.i 171. " + string(swin.rmz)).
     run savelog("swiftmaket", "swmt.i    . " + string(swin.swfield)).
     run savelog("swiftmaket", "swmt.i    . " + string(swin.content[1])).
     run savelog("swiftmaket", "swmt.i    . " + string(swin.content[2])).
     run savelog("swiftmaket", "swmt.i    . " + string(swin.content[3])).
     run savelog("swiftmaket", "swmt.i    . " + string(swin.content[4])).
     run savelog("swiftmaket", "swmt.i    . " + string(swin.content[5])).
     run savelog("swiftmaket", "swmt.i    . " + string(swin.content[6])).
     update swin.type auto-return when distype
         swin.content[1]
         swin.content[2] when discon2
         swin.content[3] when discon3
         swin.content[4] when discon4
         swin.content[5] when discon5
         swin.content[6] auto-return when discon6
         with frame ord-info editing:
             readkey.
             /* Вырежем все недопустимые символы */
             if swmt-den(keylabel(lastkey)) then bell. else apply lastkey.
             IF KEYFUNCTION(LASTKEY) = "RETURN" or KEYFUNCTION(LASTKEY) = "END-ERROR" or KEYFUNCTION(LASTKEY) = "GO" or KEYFUNCTION(LASTKEY) = "HELP" or
                lastkey = keycode(" ") or substr(KEYFUNCTION(LASTKEY),1,6) = "CURSOR" or KEYFUNCTION(LASTKEY) = "BACKSPACE" or substr(KEYFUNCTION(LASTKEY),1,3) = "DEL" or
                substr(KEYFUNCTION(LASTKEY),1,3) = "INS" or substr(KEYFUNCTION(LASTKEY),1,4) = "CTRL" or  KEYFUNCTION(LASTKEY) = "LEAVE"  then do:
                  apply lastkey.
                  if frame-field = "swin.content[1]" then apply "value-changed" to swin.content[1] in frame ord-info.
                  if frame-field = "swin.content[2]" then apply "value-changed" to swin.content[2] in frame ord-info.
             end.
         end.
     run savelog("swiftmaket", "swmt.i 196. " + string(swin.rmz)).
     run savelog("swiftmaket", "swmt.i    . " + string(swin.swfield)).
     run savelog("swiftmaket", "swmt.i    . " + string(swin.content[1])).
     run savelog("swiftmaket", "swmt.i    . " + string(swin.content[2])).
     run savelog("swiftmaket", "swmt.i    . " + string(swin.content[3])).
     run savelog("swiftmaket", "swmt.i    . " + string(swin.content[4])).
     run savelog("swiftmaket", "swmt.i    . " + string(swin.content[5])).
     run savelog("swiftmaket", "swmt.i    . " + string(swin.content[6])).
END.


/* Запись всего и вся */
procedure save-row.
    def var lerr as log init false.
    def var aerr as log init false.
    def var serr as char init "".
    def var f56  as log init false.
    def var f57err as log init false.
    def var fcountry as log init false.

     /* Тестим мандаторные поля      */
     for each swin by swin.swfield by swin.type:
            if swin.mandatory = "M" then do:
               if trim(swin.content[1])="" and not (swmt = '103' and swin.swfield = '50') then do:
                  if swin.swfield="DS" then do: /* DS заполняется только при отправке */
                     if (ourcode=0 and get-dep(userid("bank"),g-today)=1) then assign serr = serr + "~n" + swin.swfield lerr = true.
                  end. else assign serr = serr + "~n" + swin.swfield lerr = true.
               end.
               if swmt = '103' and swin.swfield = '50' and (( trim(swin.content[1] + swin.content[2] + swin.content[3] + swin.content[4] + swin.content[5] +
                  swin.content[6]) = "") or (swin.content[1] + swin.content[2] + swin.content[3] + swin.content[4] + swin.content[5] + swin.content[6] = ?)) then do:
                  assign serr = serr + "~n" + swin.swfield lerr = true.
                  run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "swmt.i 260~n" + s-remtrz + " " + g-ofc, "1", "", "").
               end.
            end.
            if swin.swfield = "56" then do:
               if swin.type <> "N" then f56 = true.
            end.
            if swin.swfield = "57" and f56 then do:
              if swin.type = "N" then assign aerr = true serr = "При заполненом поле 56 обязательно заполняется поле 57~n".
            end.
            /* sasco : обработка 71 поля */
            if swin.type <>"" and swin.type <> "N" and swin.swfield = "71" and swin.type = "F" then do:
               find b-swin where b-swin.swfield = '71' and b-swin.type = 'A' no-error.
               /* 71A = OUR поэтому 71F запрещено */
               if b-swin.content[1] = 'OUR' then
                 assign swin.content[1] = ''
                        swin.content[2] = ''
                        swin.content[3] = ''
                        swin.content[4] = ''
                        swin.content[5] = ''
                        swin.content[6] = ''.
               /* 71A = BEN поэтому 71F обязательно */
               if b-swin.content[1] = 'BEN' and trim(swin.content[1] + swin.content[2] + swin.content[3] + swin.content[4] + swin.content[5] + swin.content[6]) = "" then
                  assign aerr = true serr = serr + "Если поле 71A = BEN, то обязательно заполняется поле 71F~n".
            end. else /* обязательность 33 поля в случае 71 = sha | ben */
                if swin.swfield = "33" and swmt = "103" and trim(swin.content[1]) = '' then do:
                   find b-swin where b-swin.swfield = '71' and b-swin.type = 'A' no-error.
                   if available b-swin then do:
                      if b-swin.content[1] = 'BEN' or b-swin.content[1] = 'SHA' then
                         assign aerr = true serr = serr + "Если поле 71A = " + b-swin.content[1] + ", то обязательно заполняется поле 33B~n".
                   end.
                end. else if swin.type <>"" and swin.type <> "N" then do:
                   if trim(swin.content[1] + swin.content[2] + swin.content[3] + swin.content[4] + swin.content[5] + swin.content[6]) = "" then
                      assign aerr = true serr = serr + " Пустое поле " + swin.swfield + " c типом " + swin.type + "~n".
                end.
            if swin.swfield = "57" and swin.type = "A" then country = substr(swin.content[2],5,2).
     end.

     if lerr and (swmt='100' or swmt='103' ) then do:
        message "Не заполнены следующие обязательные поля: " + serr view-as alert-box.
        return serr.
     end.
     if aerr then do:
        message serr view-as alert-box.
        return serr.
     end.

     /* Апдэйт полей в общей таблице */
     find first swout where swout.rmz=trim(s-remtrz) and deluid = ? no-error.
     if avail swout then do:
        assign swout.editdate = today
               swout.edittime = time
               swout.edituid = userid("bank").
        if swout.mt = "202" then swout.mt  = swmt.
        release swout.
     end. else do:
        {swm-cif.i} /* Поиск кода клиента */
        create swout.
        assign swout.rmz = s-remtrz
               swout.cif = scif
               swout.mt  = swmt
               swout.credate = today
               swout.cretime = time
               swout.creuid = userid("bank")
               swout.branch = ourbank.
     end.

     /* Апдэйт содержимого макета */
     for each swin.
          find first swbody share-lock where swbody.rmz=swin.rmz and swbody.swfield = swin.swfield and ((swin.swfield='71' and swbody.type = swin.type) or (swin.swfield<>'71')) no-error.
          if avail swbody then do:
             run savelog("swiftmaket", "swmt.i 295. " + string(swin.rmz)).
             run savelog("swiftmaket", "swmt.i    . " + string(swin.swfield)).
             run savelog("swiftmaket", "swmt.i    . " + string(swin.content[1])).
             run savelog("swiftmaket", "swmt.i    . " + string(swin.content[2])).
             run savelog("swiftmaket", "swmt.i    . " + string(swin.content[3])).
             run savelog("swiftmaket", "swmt.i    . " + string(swin.content[4])).
             run savelog("swiftmaket", "swmt.i    . " + string(swin.content[5])).
             run savelog("swiftmaket", "swmt.i    . " + string(swin.content[6])).
             run toLogSWBody.
             if swmt = "103" and (index(remtrz.sqn, "IBH") > 0 or remtrz.source = "IBH") then do:
                 if swbody.swfield = '56' and swbody.type = 'A' and swin.content[1] = '' then do:
                     assign swbody.content[1]=swin.content[2]
                            swbody.type = swin.type
                            swbody.swfield = swin.swfield.
                 end. else if swbody.swfield = '57' and swbody.type = 'A' and swin.content[1] = '' then do:
                     assign swbody.content[1]=swin.content[2]
                            swbody.type = swin.type
                            swbody.swfield = swin.swfield.
                 end. else do:
                     assign swbody.content[1]=swin.content[1]
                            swbody.content[2]=swin.content[2]
                            swbody.content[3]=swin.content[3]
                            swbody.content[4]=swin.content[4]
                            swbody.content[5]=swin.content[5]
                            swbody.type = swin.type
                            swbody.swfield = swin.swfield.
                 end.
             end. else do:
                 assign swbody.content[1]=swin.content[1]
                        swbody.content[2]=swin.content[2]
                        swbody.content[3]=swin.content[3]
                        swbody.content[4]=swin.content[4]
                        swbody.content[5]=swin.content[5]
                        swbody.type = swin.type
                        swbody.swfield = swin.swfield.
             end.
             run toLogSWBody.
             release swbody.
          end. else do:
             release swbody.
             run savelog("swiftmaket", "swmt.i 312. " + string(swin.rmz)).
             run savelog("swiftmaket", "swmt.i    . " + string(swin.swfield)).
             run savelog("swiftmaket", "swmt.i    . " + string(swin.content[1])).
             run savelog("swiftmaket", "swmt.i    . " + string(swin.content[2])).
             run savelog("swiftmaket", "swmt.i    . " + string(swin.content[3])).
             run savelog("swiftmaket", "swmt.i    . " + string(swin.content[4])).
             run savelog("swiftmaket", "swmt.i    . " + string(swin.content[5])).
             run savelog("swiftmaket", "swmt.i    . " + string(swin.content[6])).
             create swbody.
             buffer-copy swin except feature descr mandatory to swbody.
             run toLogSWBody.
          end. /* if avail swbody */
     end. /* for each swin */

     /* Проставим страну */
     find first swin where swin.swfield="9f" no-lock no-error.
     if avail swin then country = swin.content[1].
     else country = substr(destination, 5, 2).

     find first sub-cod where sub-cod.acc = s-remtrz and sub-cod.sub = 'rmz' and sub-cod.d-cod = 'iso3166' no-error.
     if avail sub-cod and sub-cod.ccode =  "" then assign sub-cod.ccode = country sub-cod.rdt = today.
     if not avail sub-cod then do:
        create sub-cod.
        assign
            sub-cod.acc = s-remtrz
            sub-cod.sub = 'rmz'
            sub-cod.d-cod = 'iso3166'
            sub-cod.ccode = country
            sub-cod.rdt = today.
     end.
     {swmt-rmz.i}
     /*****************************************************************************************************/
     if remtrz.ord = ? then do:
       run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "swmt.i 393", "1", "", "").
       hide message.
       return "Не корректное поле ORD!".
     end.
     /*****************************************************************************************************/

     hide message.
     return "ok".  /* Говорим 3-outg.p что нужно отправить макет */
end. /* save-row */



procedure help-row.
    message skip
         "Enter - Редактирование поля" skip
         "F1 - Сохранение измений в редактируемом поле" skip
         "F2 - Помощь" skip
         "F4 - Отмена изменений" skip
         "Tab - Переключение между элементами окна" skip
         "Ctrl+A - Архив сообщений" skip
         "Стрелки - просмотр полей макета " skip (1)
         view-as alert-box title " Помощь ".
end.



procedure dspl-row.
 def var str as char init ''.
 def var i as integer.
 /* Формирование строки помощи возможных значений поля type */
 if swin.feature = "" then str="".
 else do:
    repeat i=1 to num-entries(swin.feature):
         case entry(i, swin.feature):
             when "A" then str = str + " A - BIC ".
             when "B" then do:
                  if swin.swfield="33" then str = str + " Валюта Сумма". else str = str + " B - BIC ".
             end.
             when "D" then str = str + " D - Address ".
             when "K" then str = str + " K - Address ".
             when "N" then str = str + " N - NONE ".
         end case.
    end.
 end.
 {swmt-i-t.i}
 {swmt-i-f.i}
 disp contentt swin.type content1 swin.content[1] content2 swin.content[2] content3 swin.content[3] swin.content[4] swin.content[5] swin.content[6] with frame ord-info.
 Message "Описание:" trim(swin.descr) str.
end.

procedure view-rows.
     def var str as char init ''.
     def var i as integer.
     /* Формирование просмотра платежа*/
     def buffer tswin for swin.
     find first ofc where ofc.ofc = userid('bank') no-lock no-error.
     if not avail ofc then do:
        run tb( 'Ошибка', '', 'Отсутствует офицер ' + userid( 'bank' ) + '!', '' ).
        return.
     end.

     output to rpt.img.
     put unformatted "Предварительный просмотр макета, " + string(today,"99.99.9999") + " " + string(time,"HH:MM:SS") " " ourbank skip(1) tmptitle skip(1).
     for each tswin no-lock by swfield.
         put unformatted skip
             tswin.mandatory  format "x(1)" " "
             tswin.swfield    format "x(2)"
             tswin.type       format "x(1)" ":" " "
             tswin.content[1] format "x(35)" skip.

         if tswin.content[2] <> "" then put unformatted tswin.content[2] at 8 format "x(35)" skip.
         if tswin.content[3] + tswin.content[4] <> "" then put unformatted tswin.content[3] + tswin.content[4] at 8 format "x(70)" skip.
         if tswin.content[5] + tswin.content[6] <> "" then put unformatted tswin.content[5] + tswin.content[6] at 8 format "x(70)" skip.
     end.

     put unformatted skip(1) '    Подпись банка:   ' ofc.name " ("  trim(ofc.ofc) ") " skip(1).
     output close.
     run menu-prt("rpt.img").
end.



procedure toLogSWBody:
   run savelog("swiftmaket",  "swmt.i  swbody.rmz         " + comm.swbody.rmz) no-error.
   run savelog("swiftmaket",  "swmt.i  swbody.swfield     " + comm.swbody.swfield) no-error.
   run savelog("swiftmaket",  "swmt.i  swbody.type        " + comm.swbody.type) no-error.
   run savelog("swiftmaket",  "swmt.i  swbody.content[1]  " + comm.swbody.content[1]) no-error.
   run savelog("swiftmaket",  "swmt.i  swbody.content[2]  " + comm.swbody.content[2]) no-error.
   run savelog("swiftmaket",  "swmt.i  swbody.content[3]  " + comm.swbody.content[3]) no-error.
   run savelog("swiftmaket",  "swmt.i  swbody.content[4]  " + comm.swbody.content[4]) no-error.
   run savelog("swiftmaket",  "swmt.i  swbody.content[5]  " + comm.swbody.content[5]) no-error.
   run savelog("swiftmaket",  "swmt.i  swbody.content[6]  " + comm.swbody.content[6]) no-error.
end procedure.