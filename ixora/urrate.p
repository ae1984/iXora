/* kasmd.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Проверка состояния ARP касса в пути
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
 * BASES
        BANK COMM
 * AUTHOR
         30/03/2010 id00004
 * CHANGES
         02.04.2010 id00004 - Добавил проверку на  существующие периоды
         23.05.2013 evseev - tz-1844
         05.06.2013 evseev - tz-1845
         12/10/2013 Luiza  - ТЗ 1923 синхронизация изменений по филиалам
*/


{global.i}

   def var v-rsrate as char.
   def var v-rstrn as char.
   def var v-days as char.
   def buffer b-rtur for rtur.

    def new shared temp-table wrk like rtur.
    def new shared temp-table wrkdel like rtur.

    def new shared var ll-ourbank as char no-undo.
    find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
    if not avail sysc or sysc.chval = "" then do:
     display " There is no record OURBNK in bank.sysc file !!".
     pause.
     return.
    end.
    ll-ourbank = trim(sysc.chval).

    def var vold-cod  as char.
    def var vold-trm  as char.
    def var vold-rate as char.
    def var vold-day  as char.

   define frame fcas
          rtur.cod format "x(3)" validate(rtur.cod = "KZT" or rtur.cod = "EUR" or rtur.cod = "USD" , "Неверный код валюты") label "Валюта" help "KZT - тенге;  USD - доллары; EUR - евро  "   skip
          v-rstrn format "x(3)" label   "Период" skip
          v-days  format "x(1)" validate(v-days = "d" or v-days = "", "Неверный признак") label   "Д/м   "  help "d - период в днях;  Пусто - период в месяцах  "  skip
          v-rsrate format "x(7)" label  "Ставка"
          with side-labels centered row 5.
   DEFINE QUERY q1 FOR rtur.
   define buffer buf for rtur.
   define browse b1
   query q1
   displ
        rtur.cod  format "x(3)" label "Валюта "
        string(rtur.trm)  format "x(10)" label "Период "
        if substr(rtur.rem,3,1) = "d" then "день" else "месяц"  format "x(5)" label            "д/м "
        string(rtur.rate) format "x(6)"  label "Ставка "
        string(rtur.who) format "x(7)"   label "Логин  "
        with 17 down  title "Настройка депозита СРОЧНЫЙ" overlay.
   DEFINE BUTTON badd LABEL "Добавить"   .
   DEFINE BUTTON bRedakt LABEL "Изменить".
   DEFINE BUTTON bsinh LABEL "Синхронизация с филиалами"    .
   DEFINE BUTTON brem LABEL "Удалить"    .
   DEFINE BUTTON bexit LABEL "Выход"     .
   def frame fr1 b1 skip badd bRedakt brem bsinh bexit  with centered overlay row 3 top-only.



   define frame fcas1
      rtur.cod format "x(3)" validate(rtur.cod = "KZT" or rtur.cod = "EUR" or rtur.cod = "USD" , "Неверный код валюты") label "Валюта"   skip
      v-rstrn format "x(3)" label   "Период" skip
      v-rsrate format "x(7)" label  "Ставка"
      with side-labels centered row 5.
   DEFINE QUERY q2 FOR rtur.
   define buffer buf1 for rtur.
   def browse b2 query q2 displ
       rtur.cod  format "x(3)" label "Валюта "
       string(rtur.trm)  format "x(10)" label "Период"
       string(rtur.rate) format "x(6)" label "Ставка %"
       string(rtur.who) format "x(7)" label "Логин"
       with 17 down  title "Настройка депозита" overlay.
   DEFINE BUTTON badd1 LABEL "Добавить"   .
   DEFINE BUTTON bRedakt1 LABEL "Изменить".
   DEFINE BUTTON brem1 LABEL "Удалить"    .
   DEFINE BUTTON bsinh1 LABEL "Синхронизация с филиалами"    .
   DEFINE BUTTON bexit1 LABEL "Выход"     .
   def frame fr2 b2 skip badd1 bRedakt1 brem1 bsinh1 bexit1 with centered overlay row 3 top-only.


    on "END-ERROR" of frame fr1 do:
        find first wrk no-lock no-error.
        find first wrkdel no-lock no-error.
        if available wrk or available wrkdel then do:
            MESSAGE "Были проведены изменения,синхронизировать по филиалам?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                {r-branch.i &proc = "urrate_txb"}
                empty temp-table wrk.
                empty temp-table wrkdel.
            end.
        end.
    end.

    on "END-ERROR" of frame fr2 do:
        find first wrk no-lock no-error.
        find first wrkdel no-lock no-error.
        if available wrk or available wrkdel then do:
            MESSAGE "Были проведены изменения,синхронизировать по филиалам?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                {r-branch.i &proc = "urrate_txb"}
                empty temp-table wrk.
                empty temp-table wrkdel.
            end.
        end.
    end.

   run sel ("Выберите тип депозита", "Срочный |Накопительный|Forte Profitable|Forte Profitable (ежм.выпл.)|Forte Universal |Forte Maximum|Forte Special").
   if int(return-value) = 1 then do:  /*срочный*/

     ON CHOOSE OF badd IN FRAME fr1 do:
        create rtur.
        update rtur.cod v-rstrn v-days  v-rsrate  with frame fcas.
        if v-days = "m" then v-days = "".
        if v-days = "d"then do:
           find last b-rtur where b-rtur.trm = integer(v-rstrn)  and b-rtur.who = g-ofc and b-rtur.rem = "SR" + v-days no-lock no-error.
           if avail b-rtur then do:
              message "Данный период уже существует" view-as alert-box.
              return.
           end.
        end. else do:
            find last b-rtur where b-rtur.trm = integer(v-rstrn)  and b-rtur.who = g-ofc and (b-rtur.rem = "SR" + v-days or b-rtur.rem = "SR") no-lock no-error.
            if avail b-rtur then do:
               message "Данный период уже существует" view-as alert-box.
               return.
            end.
        end.
        rtur.trm = integer(v-rstrn) .
        rtur.rate = decimal(v-rsrate).
        rtur.who = g-ofc.
        rtur.whn = g-today.
        rtur.rem = "SR" + v-days.
        run addwrk.
        hide frame fcas.
        open query q1 for each rtur where rtur.rem begins "SR" no-lock by rtur.cod by rtur.trm .
     end.

     ON CHOOSE OF bRedakt IN FRAME fr1 do:
        find buf where rowid (buf) = rowid (rtur) exclusive-lock no-error.
        if avail buf then do:
           v-rstrn = string(rtur.trm).
           v-rsrate = string(rtur.rate).
           displ  rtur.cod v-rstrn v-days v-rsrate  with frame fcas.
           assign vold-cod  = rtur.cod vold-trm = v-rstrn vold-rate = v-rsrate vold-day = v-days.
           update rtur.cod v-rstrn v-days v-rsrate with frame fcas.
           if v-days = "m" then v-days = "".
           rtur.trm = integer(v-rstrn).
           rtur.rate = decimal(v-rsrate).
           rtur.who = g-ofc.
           rtur.rem = "SR" + v-days.
           rtur.whn = g-today.
           if vold-cod  <> rtur.cod or vold-trm <> v-rstrn or vold-rate <> v-rsrate or vold-day <> v-days then run addwrk.
           hide frame fcas.
           open query q1 for each rtur where rtur.rem begins "SR" no-lock by rtur.cod by rtur.trm .
        end.
     end.

     ON CHOOSE OF brem IN FRAME fr1 do:
        find buf where rowid (buf) = rowid (rtur) exclusive-lock no-error.
        if avail buf then do:
            MESSAGE "Вы действительно хотите удалить запись?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                run savelog( "rtur", "Ставки по депозитам Юр. лиц удаление филиал: " + ll-ourbank + " " + rtur.cod + " " + string(rtur.trm) + " " + string(rtur.rate)  + " " + rtur.who + " " + rtur.rem).
                run delwrk.
                delete buf.
                browse b1:refresh().
            end.
        end.
     end.

     ON CHOOSE OF bsinh IN FRAME fr1 do:
        find first wrk no-lock no-error.
        find first wrkdel no-lock no-error.
        if available wrk or available wrkdel then do:
            MESSAGE "Синхронизировать изменения по филиалам?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                {r-branch.i &proc = "urrate_txb"}
                empty temp-table wrk.
                empty temp-table wrkdel.
            end.
        end.
        else message "Изменений не было." view-as alert-box.
     end.

     ON CHOOSE OF bexit IN FRAME fr1 do:
        find first wrk no-lock no-error.
        find first wrkdel no-lock no-error.
        if available wrk or available wrkdel then do:
            MESSAGE "Были проведены изменения,синхронизировать по филиалам?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                {r-branch.i &proc = "urrate_txb"}
                empty temp-table wrk.
                empty temp-table wrkdel.
            end.
        end.
        hide frame fr1.
        APPLY "WINDOW-CLOSE" TO BROWSE b1.
     end.

     open query q1 for each rtur where rtur.rem begins "SR" no-lock by rtur.cod by rtur.rem by rtur.trm    .
     b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
     ENABLE all with frame fr1 centered overlay top-only.
     apply "value-changed" to b1 in frame fr1.
     WAIT-FOR WINDOW-CLOSE of frame fr1.
   end.


   if int(return-value) = 2 then do:  /*Накопительный*/
     ON CHOOSE OF badd1 IN FRAME fr2 do:
        create rtur.
        update rtur.cod v-rstrn v-rsrate  with frame fcas1.
        rtur.trm = integer(v-rstrn) .
        rtur.rate = decimal(v-rsrate).
        rtur.who = g-ofc.
        rtur.rem = "NK".
        rtur.whn = g-today.
        run addwrk.

        hide frame fcas1.
        open query q2 for each rtur where rtur.rem = "NK" no-lock by rtur.cod by rtur.rem by rtur.trm.
     end.

     ON CHOOSE OF bRedakt1 IN FRAME fr2 do:
        find buf1 where rowid (buf1) = rowid (rtur) exclusive-lock no-error.
        if avail buf1 then do:
           v-rstrn = string(rtur.trm).
           v-rsrate = string(rtur.rate).
           displ  rtur.cod v-rstrn v-rsrate  with frame fcas1.
           assign vold-cod  = rtur.cod vold-trm = v-rstrn vold-rate = v-rsrate.
           update rtur.cod v-rstrn v-rsrate with frame fcas1.
           rtur.trm = integer(v-rstrn).
           rtur.rate = decimal(v-rsrate).
           rtur.who = g-ofc.
           rtur.whn = g-today.
           if vold-cod  <> rtur.cod or vold-trm <> v-rstrn or vold-rate <> v-rsrate then run addwrk.
           hide frame fcas1.
           open query q2 for each rtur where rtur.rem = "NK" no-lock by rtur.cod by rtur.rem by rtur.trm.
        end.
     end.

     ON CHOOSE OF brem1 IN FRAME fr2 do:
        find buf1 where rowid (buf1) = rowid (rtur) exclusive-lock no-error.
        if avail buf1 then do:
            MESSAGE "Вы действительно хотите удалить запись?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                run savelog( "rtur", "Ставки по депозитам Юр. лиц удаление филиал: " + ll-ourbank + " " + rtur.cod + " " + string(rtur.trm) + " " + string(rtur.rate)  + " " + rtur.who + " " + rtur.rem).
                run delwrk.
                delete buf1.
                browse b2:refresh().
            end.
        end.
     end.

     ON CHOOSE OF bsinh1 IN FRAME fr2 do:
        find first wrk no-lock no-error.
        find first wrkdel no-lock no-error.
        if available wrk or available wrkdel then do:
            MESSAGE "Синхронизировать изменения по филиалам?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                {r-branch.i &proc = "urrate_txb"}
                empty temp-table wrk.
                empty temp-table wrkdel.
            end.
        end.
        else message "Изменений не было." view-as alert-box.
     end.

     ON CHOOSE OF bexit1 IN FRAME fr2 do:
        find first wrk no-lock no-error.
        find first wrkdel no-lock no-error.
        if available wrk or available wrkdel then do:
            MESSAGE "Были проведены изменения,синхронизировать по филиалам?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                {r-branch.i &proc = "urrate_txb"}
                empty temp-table wrk.
                empty temp-table wrkdel.
            end.
        end.
        hide frame fr2.
        APPLY "WINDOW-CLOSE" TO BROWSE b2.
     end.

     open query q2 for each rtur where rtur.rem = "NK" no-lock by rtur.cod by rtur.rem by rtur.trm.
     b2:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
     ENABLE all with frame fr2 centered overlay top-only.
     apply "value-changed" to b2 in frame fr2.
     WAIT-FOR WINDOW-CLOSE of frame fr2.
   end.


   if int(return-value) = 3 then do:  /*Forte Profitable*/
     ON CHOOSE OF badd1 IN FRAME fr2 do:
        create rtur.
        update rtur.cod v-rstrn v-rsrate  with frame fcas1.
        rtur.trm = integer(v-rstrn) .
        rtur.rate = decimal(v-rsrate).
        rtur.who = g-ofc.
        rtur.rem = "ForteProfitable".
        rtur.whn = g-today.
        run addwrk.

        hide frame fcas1.
        open query q2 for each rtur where rtur.rem = "ForteProfitable" no-lock by rtur.cod by rtur.rem by rtur.trm.
     end.

     ON CHOOSE OF bRedakt1 IN FRAME fr2 do:
        find buf1 where rowid (buf1) = rowid (rtur) exclusive-lock no-error.
        if avail buf1 then do:
           v-rstrn = string(rtur.trm).
           v-rsrate = string(rtur.rate).
           displ  rtur.cod v-rstrn v-rsrate  with frame fcas1.
           assign vold-cod  = rtur.cod vold-trm = v-rstrn vold-rate = v-rsrate.
           update rtur.cod v-rstrn v-rsrate with frame fcas1.
           rtur.trm = integer(v-rstrn).
           rtur.rate = decimal(v-rsrate).
           rtur.who = g-ofc.
           rtur.whn = g-today.
           if vold-cod  <> rtur.cod or vold-trm <> v-rstrn or vold-rate <> v-rsrate then run addwrk.
           hide frame fcas1.
           open query q2 for each rtur where rtur.rem = "ForteProfitable" no-lock by rtur.cod by rtur.rem by rtur.trm.
        end.
     end.

     ON CHOOSE OF brem1 IN FRAME fr2 do:
        find buf1 where rowid (buf1) = rowid (rtur) exclusive-lock no-error.
        if avail buf1 then do:
            MESSAGE "Вы действительно хотите удалить запись?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                run savelog( "rtur", "Ставки по депозитам Юр. лиц удаление филиал: " + ll-ourbank + " " + rtur.cod + " " + string(rtur.trm) + " " + string(rtur.rate)  + " " + rtur.who + " " + rtur.rem).
                run delwrk.
                delete buf1.
                browse b2:refresh().
            end.
        end.
     end.
     ON CHOOSE OF bsinh1 IN FRAME fr2 do:
        find first wrk no-lock no-error.
        find first wrkdel no-lock no-error.
        if available wrk or available wrkdel then do:
            MESSAGE "Синхронизировать изменения по филиалам?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                {r-branch.i &proc = "urrate_txb"}
                empty temp-table wrk.
                empty temp-table wrkdel.
            end.
        end.
        else message "Изменений не было." view-as alert-box.
     end.

     ON CHOOSE OF bexit1 IN FRAME fr2 do:
        find first wrk no-lock no-error.
        find first wrkdel no-lock no-error.
        if available wrk or available wrkdel then do:
            MESSAGE "Были проведены изменения,синхронизировать по филиалам?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                {r-branch.i &proc = "urrate_txb"}
                empty temp-table wrk.
                empty temp-table wrkdel.
            end.
        end.
        hide frame fr2.
        APPLY "WINDOW-CLOSE" TO BROWSE b2.
     end.

     open query q2 for each rtur where rtur.rem = "ForteProfitable" no-lock by rtur.cod by rtur.rem by rtur.trm.
     b2:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
     ENABLE all with frame fr2 centered overlay top-only.
     apply "value-changed" to b2 in frame fr2.
     WAIT-FOR WINDOW-CLOSE of frame fr2.
   end.

   if int(return-value) = 4 then do:  /*Forte Profitable ежм. выпл*/
     ON CHOOSE OF badd1 IN FRAME fr2 do:
        create rtur.
        update rtur.cod v-rstrn v-rsrate  with frame fcas1.
        rtur.trm = integer(v-rstrn) .
        rtur.rate = decimal(v-rsrate).
        rtur.who = g-ofc.
        rtur.rem = "ForteProfitable1".
        rtur.whn = g-today.
        run addwrk.

        hide frame fcas1.
        open query q2 for each rtur where rtur.rem = "ForteProfitable1" no-lock by rtur.cod by rtur.rem by rtur.trm.
     end.

     ON CHOOSE OF bRedakt1 IN FRAME fr2 do:
        find buf1 where rowid (buf1) = rowid (rtur) exclusive-lock no-error.
        if avail buf1 then do:
           v-rstrn = string(rtur.trm).
           v-rsrate = string(rtur.rate).
           displ  rtur.cod v-rstrn v-rsrate  with frame fcas1.
           assign vold-cod  = rtur.cod vold-trm = v-rstrn vold-rate = v-rsrate.
           update rtur.cod v-rstrn v-rsrate with frame fcas1.
           rtur.trm = integer(v-rstrn).
           rtur.rate = decimal(v-rsrate).
           rtur.who = g-ofc.
           rtur.whn = g-today.
           if vold-cod  <> rtur.cod or vold-trm <> v-rstrn or vold-rate <> v-rsrate then run addwrk.
           hide frame fcas1.
           open query q2 for each rtur where rtur.rem = "ForteProfitable1" no-lock by rtur.cod by rtur.rem by rtur.trm.
        end.
     end.

     ON CHOOSE OF brem1 IN FRAME fr2 do:
        find buf1 where rowid (buf1) = rowid (rtur) exclusive-lock no-error.
        if avail buf1 then do:
            MESSAGE "Вы действительно хотите удалить запись?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                run savelog( "rtur", "Ставки по депозитам Юр. лиц удаление филиал: " + ll-ourbank + " " + rtur.cod + " " + string(rtur.trm) + " " + string(rtur.rate)  + " " + rtur.who + " " + rtur.rem).
                run delwrk.
                delete buf1.
                browse b2:refresh().
            end.
        end.
     end.

     ON CHOOSE OF bsinh1 IN FRAME fr2 do:
        find first wrk no-lock no-error.
        find first wrkdel no-lock no-error.
        if available wrk or available wrkdel then do:
            MESSAGE "Синхронизировать изменения по филиалам?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                {r-branch.i &proc = "urrate_txb"}
                empty temp-table wrk.
                empty temp-table wrkdel.
            end.
        end.
        else message "Изменений не было." view-as alert-box.
     end.

     ON CHOOSE OF bexit1 IN FRAME fr2 do:
        find first wrk no-lock no-error.
        find first wrkdel no-lock no-error.
        if available wrk or available wrkdel then do:
            MESSAGE "Были проведены изменения,синхронизировать по филиалам?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                {r-branch.i &proc = "urrate_txb"}
                empty temp-table wrk.
                empty temp-table wrkdel.
            end.
        end.
        hide frame fr2.
        APPLY "WINDOW-CLOSE" TO BROWSE b2.
     end.

     open query q2 for each rtur where rtur.rem = "ForteProfitable1" no-lock by rtur.cod by rtur.rem by rtur.trm.
     b2:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
     ENABLE all with frame fr2 centered overlay top-only.
     apply "value-changed" to b2 in frame fr2.
     WAIT-FOR WINDOW-CLOSE of frame fr2.
   end.



   if int(return-value) = 5 then do:  /*Forte Universal*/
     ON CHOOSE OF badd1 IN FRAME fr2 do:
        create rtur.
        update rtur.cod v-rstrn v-rsrate  with frame fcas1.
        rtur.trm = integer(v-rstrn) .
        rtur.rate = decimal(v-rsrate).
        rtur.who = g-ofc.
        rtur.rem = "ForteUniversal".
        rtur.whn = g-today.
        run addwrk.
        hide frame fcas1.
        open query q2 for each rtur where rtur.rem = "ForteUniversal" no-lock by rtur.cod by rtur.rem by rtur.trm.
     end.

     ON CHOOSE OF bRedakt1 IN FRAME fr2 do:
        find buf1 where rowid (buf1) = rowid (rtur) exclusive-lock no-error.
        if avail buf1 then do:
           v-rstrn = string(rtur.trm).
           v-rsrate = string(rtur.rate).
           displ  rtur.cod v-rstrn v-rsrate  with frame fcas1.
           assign vold-cod  = rtur.cod vold-trm = v-rstrn vold-rate = v-rsrate.
           update rtur.cod v-rstrn v-rsrate with frame fcas1.
           rtur.trm = integer(v-rstrn).
           rtur.rate = decimal(v-rsrate).
           rtur.who = g-ofc.
           rtur.whn = g-today.
           if vold-cod  <> rtur.cod or vold-trm <> v-rstrn or vold-rate <> v-rsrate then run addwrk.
           hide frame fcas1.
           open query q2 for each rtur where rtur.rem = "ForteUniversal" no-lock by rtur.cod by rtur.rem by rtur.trm.
        end.
     end.

     ON CHOOSE OF brem1 IN FRAME fr2 do:
        find buf1 where rowid (buf1) = rowid (rtur) exclusive-lock no-error.
        if avail buf1 then do:
            MESSAGE "Вы действительно хотите удалить запись?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                run savelog( "rtur", "Ставки по депозитам Юр. лиц удаление филиал: " + ll-ourbank + " " + rtur.cod + " " + string(rtur.trm) + " " + string(rtur.rate)  + " " + rtur.who + " " + rtur.rem).
                run delwrk.
                delete buf1.
                browse b2:refresh().
            end.
        end.
     end.

     ON CHOOSE OF bsinh1 IN FRAME fr2 do:
        find first wrk no-lock no-error.
        find first wrkdel no-lock no-error.
        if available wrk or available wrkdel then do:
            MESSAGE "Синхронизировать изменения по филиалам?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                {r-branch.i &proc = "urrate_txb"}
                empty temp-table wrk.
                empty temp-table wrkdel.
            end.
        end.
        else message "Изменений не было." view-as alert-box.
     end.

     ON CHOOSE OF bexit1 IN FRAME fr2 do:
        find first wrk no-lock no-error.
        find first wrkdel no-lock no-error.
        if available wrk or available wrkdel then do:
            MESSAGE "Были проведены изменения,синхронизировать по филиалам?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                {r-branch.i &proc = "urrate_txb"}
                empty temp-table wrk.
                empty temp-table wrkdel.
            end.
        end.
        hide frame fr2.
        APPLY "WINDOW-CLOSE" TO BROWSE b2.
     end.

     open query q2 for each rtur where rtur.rem = "ForteUniversal" no-lock by rtur.cod by rtur.rem by rtur.trm.
     b2:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
     ENABLE all with frame fr2 centered overlay top-only.
     apply "value-changed" to b2 in frame fr2.
     WAIT-FOR WINDOW-CLOSE of frame fr2.
   end.



   if int(return-value) = 6 then do:  /*Forte Maximum*/
     ON CHOOSE OF badd1 IN FRAME fr2 do:
        create rtur.
        update rtur.cod v-rstrn v-rsrate  with frame fcas1.
        rtur.trm = integer(v-rstrn) .
        rtur.rate = decimal(v-rsrate).
        rtur.who = g-ofc.
        rtur.rem = "ForteMaximum".
        rtur.whn = g-today.
        run addwrk.
        hide frame fcas1.
        open query q2 for each rtur where rtur.rem = "ForteMaximum" no-lock by rtur.cod by rtur.rem by rtur.trm.
     end.

     ON CHOOSE OF bRedakt1 IN FRAME fr2 do:
        find buf1 where rowid (buf1) = rowid (rtur) exclusive-lock no-error.
        if avail buf1 then do:
           v-rstrn = string(rtur.trm).
           v-rsrate = string(rtur.rate).
           displ  rtur.cod v-rstrn v-rsrate  with frame fcas1.
           assign vold-cod  = rtur.cod vold-trm = v-rstrn vold-rate = v-rsrate.
           update rtur.cod v-rstrn v-rsrate with frame fcas1.
           rtur.trm = integer(v-rstrn).
           rtur.rate = decimal(v-rsrate).
           rtur.who = g-ofc.
           rtur.whn = g-today.
           if vold-cod  <> rtur.cod or vold-trm <> v-rstrn or vold-rate <> v-rsrate then run addwrk.
           hide frame fcas1.
           open query q2 for each rtur where rtur.rem = "ForteMaximum" no-lock by rtur.cod by rtur.rem by rtur.trm.
        end.
     end.

     ON CHOOSE OF brem1 IN FRAME fr2 do:
        find buf1 where rowid (buf1) = rowid (rtur) exclusive-lock no-error.
        if avail buf1 then do:
            MESSAGE "Вы действительно хотите удалить запись?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                run savelog( "rtur", "Ставки по депозитам Юр. лиц удаление филиал: " + ll-ourbank + " " + rtur.cod + " " + string(rtur.trm) + " " + string(rtur.rate)  + " " + rtur.who + " " + rtur.rem).
                run delwrk.
                delete buf1.
                browse b2:refresh().
            end.
        end.
     end.

     ON CHOOSE OF bsinh1 IN FRAME fr2 do:
        find first wrk no-lock no-error.
        find first wrkdel no-lock no-error.
        if available wrk or available wrkdel then do:
            MESSAGE "Синхронизировать изменения по филиалам?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                {r-branch.i &proc = "urrate_txb"}
                empty temp-table wrk.
                empty temp-table wrkdel.
            end.
        end.
        else message "Изменений не было." view-as alert-box.
     end.

     ON CHOOSE OF bexit1 IN FRAME fr2 do:
        find first wrk no-lock no-error.
        find first wrkdel no-lock no-error.
        if available wrk or available wrkdel then do:
            MESSAGE "Были проведены изменения,синхронизировать по филиалам?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                {r-branch.i &proc = "urrate_txb"}
                empty temp-table wrk.
                empty temp-table wrkdel.
            end.
        end.
        hide frame fr2.
        APPLY "WINDOW-CLOSE" TO BROWSE b2.
     end.

     open query q2 for each rtur where rtur.rem = "ForteMaximum" no-lock by rtur.cod by rtur.rem by rtur.trm.
     b2:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
     ENABLE all with frame fr2 centered overlay top-only.
     apply "value-changed" to b2 in frame fr2.
     WAIT-FOR WINDOW-CLOSE of frame fr2.
   end.




   if int(return-value) = 7 then do:  /*Forte Special*/
     ON CHOOSE OF badd1 IN FRAME fr2 do:
        create rtur.
        update rtur.cod v-rstrn v-rsrate  with frame fcas1.
        rtur.trm = integer(v-rstrn) .
        rtur.rate = decimal(v-rsrate).
        rtur.who = g-ofc.
        rtur.rem = "ForteSpecial".
        rtur.whn = g-today.
        run addwrk.
        hide frame fcas1.
        open query q2 for each rtur where rtur.rem = "ForteSpecial" no-lock by rtur.cod by rtur.rem by rtur.trm.
     end.

     ON CHOOSE OF bRedakt1 IN FRAME fr2 do:
        find buf1 where rowid (buf1) = rowid (rtur) exclusive-lock no-error.
        if avail buf1 then do:
           v-rstrn = string(rtur.trm).
           v-rsrate = string(rtur.rate).
           displ  rtur.cod v-rstrn v-rsrate  with frame fcas1.
           assign vold-cod  = rtur.cod vold-trm = v-rstrn vold-rate = v-rsrate.
           update rtur.cod v-rstrn v-rsrate with frame fcas1.
           rtur.trm = integer(v-rstrn).
           rtur.rate = decimal(v-rsrate).
           rtur.who = g-ofc.
           rtur.whn = g-today.
           if vold-cod  <> rtur.cod or vold-trm <> v-rstrn or vold-rate <> v-rsrate then run addwrk.
           hide frame fcas1.
           open query q2 for each rtur where rtur.rem = "ForteSpecial" no-lock by rtur.cod by rtur.rem by rtur.trm.
        end.
     end.

     ON CHOOSE OF brem1 IN FRAME fr2 do:
        find buf1 where rowid (buf1) = rowid (rtur) exclusive-lock no-error.
        if avail buf1 then do:
            MESSAGE "Вы действительно хотите удалить запись?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                run savelog( "rtur", "Ставки по депозитам Юр. лиц удаление филиал: " + ll-ourbank + " " + rtur.cod + " " + string(rtur.trm) + " " + string(rtur.rate)  + " " + rtur.who + " " + rtur.rem).
                run delwrk.
                delete buf1.
                browse b2:refresh().
            end.
        end.
     end.

     ON CHOOSE OF bsinh1 IN FRAME fr2 do:
        find first wrk no-lock no-error.
        find first wrkdel no-lock no-error.
        if available wrk or available wrkdel then do:
            MESSAGE "Синхронизировать изменения по филиалам?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                {r-branch.i &proc = "urrate_txb"}
                empty temp-table wrk.
                empty temp-table wrkdel.
            end.
        end.
        else message "Изменений не было." view-as alert-box.
     end.

     ON CHOOSE OF bexit1 IN FRAME fr2 do:
        find first wrk no-lock no-error.
        find first wrkdel no-lock no-error.
        if available wrk or available wrkdel then do:
            MESSAGE "Были проведены изменения,синхронизировать по филиалам?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
                {r-branch.i &proc = "urrate_txb"}
                empty temp-table wrk.
                empty temp-table wrkdel.
            end.
        end.
        hide frame fr2.
        APPLY "WINDOW-CLOSE" TO BROWSE b2.
     end.

     open query q2 for each rtur where rtur.rem = "ForteSpecial" no-lock by rtur.cod by rtur.rem by rtur.trm.
     b2:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
     ENABLE all with frame fr2 centered overlay top-only.
     apply "value-changed" to b2 in frame fr2.
     WAIT-FOR WINDOW-CLOSE of frame fr2.
   end.

procedure addwrk:
    find first wrk where wrk.cod = rtur.cod and wrk.trm = rtur.trm and wrk.rem = rtur.rem no-error.
    if not available wrk then create wrk.
    wrk.cod  = rtur.cod .
    wrk.trm  = rtur.trm.
    wrk.rate = rtur.rate.
    wrk.who  = rtur.who.
    wrk.whn  = rtur.whn.
    wrk.rem  = rtur.rem.
end procedure.

procedure delwrk:
    find first wrkdel where wrkdel.cod = rtur.cod and wrkdel.trm = rtur.trm and wrkdel.rem = rtur.rem no-error.
    if not available wrkdel then do:
        create wrkdel.
        wrkdel.cod  = rtur.cod .
        wrkdel.trm  = rtur.trm.
        wrkdel.rate = rtur.rate.
        wrkdel.who  = rtur.who.
        wrkdel.whn  = rtur.whn.
        wrkdel.rem  = rtur.rem.
    end.
end procedure.




