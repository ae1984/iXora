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
        09.09.2004 dpuchkov
 * CHANGES
        27.09.2012 evseev - логирование
*/






define shared temp-table tmpswbody like swbody.

procedure save-row1.
def var lerr as log init false.
def var aerr as log init false.
def var serr as char init "".
def var f56  as log init false.
def var f57err as log init false.
/*
def var valid33 as log.
*/
def var fcountry as log init false.

 /* Тестим мандаторные поля      */
 for each swin by swin.swfield by swin.type.
        run savelog("swiftmaket", "swmt1.i  42. " + string(swin.rmz)).
        run savelog("swiftmaket", "swmt1.i    . " + string(swin.swfield)).
        run savelog("swiftmaket", "swmt1.i    . " + string(swin.content[1])).
        run savelog("swiftmaket", "swmt1.i    . " + string(swin.content[2])).
        run savelog("swiftmaket", "swmt1.i    . " + string(swin.content[3])).
        run savelog("swiftmaket", "swmt1.i    . " + string(swin.content[4])).
        run savelog("swiftmaket", "swmt1.i    . " + string(swin.content[5])).
        run savelog("swiftmaket", "swmt1.i    . " + string(swin.content[6])).

        if swin.mandatory = "M" then do:
           if trim(swin.content[1])="" and not (swmt = '103' and swin.swfield = '50') then do:
              if swin.swfield="DS" /* DS заполняется только при отправке */
               then do:
                       if (ourcode=0 and get-dep(userid("bank"),g-today)=1) then assign serr = serr + "~n" + swin.swfield lerr = true.
               end.
               else assign serr = serr + "~n" + swin.swfield lerr = true.
           end.

           if swmt = '103' and swin.swfield = '50' and trim(swin.content[1] + swin.content[2] + swin.content[3] + swin.content[4] +
                               swin.content[5] + swin.content[6]) = ""
                               then assign serr = serr + "~n" + swin.swfield lerr = true.
        end.

        if swin.swfield = "56" then do:
                if swin.type <> "N" then f56 = true.
        end.
        if swin.swfield = "57" and f56 then do:
                if swin.type = "N" then assign aerr = true
                   serr = "При заполненом поле 56 обязательно заполняется поле 57~n".
        end.

        /* sasco : обработка 71 поля */
        if swin.type <>"" and swin.type <> "N" and swin.swfield = "71" and swin.type = "F" then do:

                find b-swin where b-swin.swfield = '71' and b-swin.type = 'A' no-error.

                /* 71A = OUR поэтому 71F запрещено */
                if b-swin.content[1] = 'OUR' then assign swin.content[1] = ''
                                                         swin.content[2] = ''
                                                         swin.content[3] = ''
                                                         swin.content[4] = ''
                                                         swin.content[5] = ''
                                                         swin.content[6] = ''.

                /* 71A = BEN поэтому 71F обязательно */
                if b-swin.content[1] = 'BEN' and
                   trim(swin.content[1] + swin.content[2] + swin.content[3] + swin.content[4] +
                   swin.content[5] + swin.content[6]) = "" then
                   assign aerr = true
                          serr = serr + "Если поле 71A = BEN, то обязательно заполняется поле 71F~n".

        end.
        else
        /* обязательность 33 поля в случае 71 = sha | ben */
        if swin.swfield = "33" and swmt = "103" and trim(swin.content[1]) = '' then do:
           find b-swin where b-swin.swfield = '71' and b-swin.type = 'A' no-error.
           if available b-swin then do:
              if b-swin.content[1] = 'BEN' or b-swin.content[1] = 'SHA' then
                 assign aerr = true
                        serr = serr + "Если поле 71A = " + b-swin.content[1] + ", то обязательно заполняется поле 33B~n".
           end.
        end.
        else
        if swin.type <>"" and swin.type <> "N" then do:
                if trim(swin.content[1] + swin.content[2] + swin.content[3] + swin.content[4] +
                   swin.content[5] + swin.content[6]) = "" then
                   assign aerr = true
                          serr = serr + " Пустое поле " + swin.swfield + " c типом " + swin.type + "~n".
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
                release swout.
 end.
 else do:
                {swm-cif.i} /* Поиск кода клиента */
                create swout.
                assign swout.rmz = s-remtrz
                       swout.cif = scif
                       swout.mt  = swmt
                       swout.credate = today
                       swout.cretime = time
                       swout.creuid = userid("bank").
                assign swout.branch = ourbank.
 end.


 /* Апдэйт содержимого макета */
 for each swin.

  find first tmpswbody share-lock where tmpswbody.rmz=swin.rmz and
             tmpswbody.swfield = swin.swfield and
             ((swin.swfield='71' and tmpswbody.type = swin.type) or (swin.swfield<>'71')) no-error.
  if avail tmpswbody then do:
     assign tmpswbody.content[1]=swin.content[1]
            tmpswbody.content[2]=swin.content[2]
            tmpswbody.content[3]=swin.content[3]
            tmpswbody.content[4]=swin.content[4]
            tmpswbody.content[5]=swin.content[5]
            tmpswbody.type = swin.type
            tmpswbody.swfield = swin.swfield.
     release tmpswbody.
   end.
   else do:
     release tmpswbody.
     create tmpswbody.
     buffer-copy swin except feature descr mandatory to tmpswbody.
   end. /* if avail tmpswbody */
 end. /* for each swin */

 /* Проставим страну */
 {swmt-rmz.i}
 /*****************************************************************************************************/
 if remtrz.ord = ? then
 do:
   run mail("IXqueuerr@fortebank.com", "bankadm@metrocombank.kz", "Поле ORD = ?", "swmt1.i 158", "1", "", "").
 end.
 /*****************************************************************************************************/

 hide message.
 return "ok".  /* Говорим 3-outg.p что нужно отправить макет */
end. /* save-row */






