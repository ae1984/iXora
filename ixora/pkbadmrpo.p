/* pkbadmrpo.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        мини отчет одного человека в ЧЕРНОМ СПИСКЕ
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        4-6-10
 * AUTHOR
        15.10.2004 tsoy
 * CHANGES
        18.10.2004 tsoy Добавил телефон
        08/09/2005 madiar в связи с изменениями в pkcash.i
        04/02/2010 madiyar - перекомпиляция в связи с добавление поля в таблице londebt
        08/02/2010 madiyar - перекомпиляция
*/

{global.i}

def var v-bank as char.
def var s-ourbank as char.

define variable datums  as date format "99/99/9999" .

def var v-cif as char.
def var v-lon like lon.lon.

def input parameter p-rid as char.

def temp-table t-tmp
  field dt     as date
  field fio    as char
  field dog    as char
  field lonamt as deci
  field dt1    as date
  field dt2    as date
  field job    as char
  field homep  as char
  field homef  as char
  field imush  as char
  field avto       as char
  field drbanki    as char
  field family     as char
  field damt       as deci
  field days       as int.

{comm-txb.i}
v-bank =  comm-txb().
s-ourbank = comm-txb().

datums   = g-today.

define stream m-out.
output stream m-out to pkbadmrpo.html.

find pkbadlst where rowid(pkbadlst) = to-rowid(p-rid) no-lock no-error.

find last cif where cif.jss = pkbadlst.rnn no-lock no-error.

if avail cif then
   find last lon where lon.cif = cif.cif no-lock no-error.
else do:
   message "Не найден код клиента по РНН" view-as alert-box.
   return.
end.

if not avail lon then do:
    message "Не найден кредит для клиента " cif.cif view-as alert-box.
    return.
end.

def var v-str as char.
def var v-delim as char init "^".

v-cif =  cif.cif.
v-lon =  lon.lon.

create t-tmp.
        t-tmp.dt              = today.
        t-tmp.fio             = trim(caps(pkbadlst.lname)) + " " + trim(caps(pkbadlst.fname)) + " " + trim(caps(pkbadlst.mname)).

        find loncon where loncon.lon = lon.lon no-lock.

        t-tmp.dog             = loncon.lcnt.
        t-tmp.lonamt          = lon.opnamt.
        t-tmp.dt1             = lon.opndt.
        t-tmp.dt2             = lon.duedt.
        t-tmp.job             = cif.ref[8].

        if cif.item <> "" then do:
              t-tmp.job = t-tmp.job + " " + entry(1, cif.item, "|").
              if num-entries(cif.item, "|") > 1 then t-tmp.job = t-tmp.job + " "  + entry(2, cif.item, "|").
        end.


       if cif.dnb <> "" then do:
              v-str = entry(1, cif.dnb, "|").
              if num-entries(v-str, v-delim) > 1 then t-tmp.homep =  entry(2, v-str, v-delim).
              if num-entries(v-str, v-delim) > 2 then t-tmp.homep =  t-tmp.homep + " д." + entry(3, v-str, v-delim).
              if num-entries(v-str, v-delim) > 3 then t-tmp.homep =  t-tmp.homep + " кв."  + entry(4, v-str, v-delim).
              if num-entries(cif.dnb, "|") > 1 then do:
                v-str = entry(2, cif.dnb, "|").
                if num-entries(v-str, v-delim) > 1 then t-tmp.homef = entry(2, v-str, v-delim).
                if num-entries(v-str, v-delim) > 2 then t-tmp.homef = t-tmp.homef + " д." +  entry(3, v-str, v-delim).
                if num-entries(v-str, v-delim) > 3 then t-tmp.homef = t-tmp.homef + " кв."  + entry(4, v-str, v-delim).
              end.
       end.

       t-tmp.homef = t-tmp.homef + " Телефон: " + cif.tel + " Сотовый " + cif.fax.
       t-tmp.job = t-tmp.job + " Телефон: " + cif.tlx .

  find pkanketa where pkanketa.lon = lon.lon and pkanketa.cif = cif.cif and pkanketa.bank = v-bank no-lock no-error.

  /* Недвижимость */
  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                and pkanketh.kritcod = "nedv" no-lock no-error.
  if avail pkanketh and pkanketh.value1 <> "" then do:
    t-tmp.imush = pkanketh.value1.

             find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                           and pkanketh.kritcod = "nedvkomn" no-lock no-error.
             if avail pkanketh and pkanketh.value1 <> "" then do:
               if t-tmp.imush <> "" then t-tmp.imush = t-tmp.imush + ", ".
               t-tmp.imush = t-tmp.imush + "колич.комнат : " + pkanketh.value1.
             end.

             find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                           and pkanketh.kritcod = "nedvsquar" no-lock no-error.
             if avail pkanketh and pkanketh.value1 <> "" then do:
               if t-tmp.imush <> "" then t-tmp.imush = t-tmp.imush + ", ".
               t-tmp.imush = t-tmp.imush + "общая площадь : " + pkanketh.value1.
             end.

             find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                           and pkanketh.kritcod = "nedvz" no-lock no-error.
             if avail pkanketh and pkanketh.value1 <> "" then do:
               if t-tmp.imush <> "" then t-tmp.imush = t-tmp.imush + ", ".
               t-tmp.imush = t-tmp.imush + "залог.обременение : " + pkanketh.value1.
             end.
  end.

  /* Автотранспорт */
  find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                and pkanketh.kritcod = "auto" no-lock no-error.
  if avail pkanketh and pkanketh.value1 <> "" then do:
    t-tmp.avto = pkanketh.value1.

             find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                           and pkanketh.kritcod = "autom" no-lock no-error.
             if avail pkanketh and pkanketh.value1 <> "" then do:
               if t-tmp.avto <> "" then t-tmp.avto = t-tmp.avto + ", ".
               t-tmp.avto = t-tmp.avto + "марка : " + pkanketh.value1.
             end.

             find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                           and pkanketh.kritcod = "autoy" no-lock no-error.
             if avail pkanketh and pkanketh.value1 <> "" then do:
               if t-tmp.avto <> "" then t-tmp.avto = t-tmp.avto + ", ".
               t-tmp.avto = t-tmp.avto + "год : " + pkanketh.value1.
             end.

             find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                           and pkanketh.kritcod = "autoz" no-lock no-error.
             if avail pkanketh and pkanketh.value1 <> "" then do:
               if t-tmp.avto <> "" then t-tmp.avto = t-tmp.avto + ", ".
               t-tmp.avto = t-tmp.avto + "залог.обременение : " + pkanketh.value1.
             end.
  end.


    find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                  and pkanketh.kritcod = "ob1" no-lock no-error.
    if avail pkanketh and pkanketh.value1 <> "" then do:
      if t-tmp.drbanki <> "" then t-tmp.drbanki = t-tmp.drbanki + ", ".
      t-tmp.drbanki = t-tmp.drbanki + "Кредит на приоб недв-ти : " + pkanketh.value1.
    end.

    find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                  and pkanketh.kritcod = "ob2" no-lock no-error.
    if avail pkanketh and pkanketh.value1 <> "" then do:
      if t-tmp.drbanki <> "" then t-tmp.drbanki = t-tmp.drbanki + ", ".
      t-tmp.drbanki = t-tmp.drbanki + " Кредит на приоб автотранс : " + pkanketh.value1.
    end.

    find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                  and pkanketh.kritcod = "ob3" no-lock no-error.
    if avail pkanketh and pkanketh.value1 <> "" then do:
      if t-tmp.drbanki <> "" then t-tmp.drbanki = t-tmp.drbanki + ", ".
      t-tmp.drbanki = t-tmp.drbanki + "  Кредит на потреб нужды : " + pkanketh.value1.
    end.

    find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                  and pkanketh.kritcod = "ob4" no-lock no-error.
    if avail pkanketh and pkanketh.value1 <> "" then do:
      if t-tmp.drbanki <> "" then t-tmp.drbanki = t-tmp.drbanki + ", ".
      t-tmp.drbanki = t-tmp.drbanki + "  Заем от работодателя  : " + pkanketh.value1.

             find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                           and pkanketh.kritcod = "ob4gar" no-lock no-error.
             if avail pkanketh and pkanketh.value1 <> "" then do:
               if t-tmp.drbanki <> "" then t-tmp.drbanki = t-tmp.drbanki + ", ".
               t-tmp.drbanki = t-tmp.drbanki + "гарант по займу : " + pkanketh.value1.
             end.

             find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                           and pkanketh.kritcod = "zalogodat" no-lock no-error.
             if avail pkanketh and pkanketh.value1 <> "" then do:
               if t-tmp.drbanki <> "" then t-tmp.drbanki = t-tmp.drbanki + ", ".
               t-tmp.drbanki = t-tmp.drbanki + "залогодатель : " + pkanketh.value1.
             end.



    end.

    find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                  and pkanketh.kritcod = "obname" no-lock no-error.
    if avail pkanketh and pkanketh.value1 <> "" then do:
      if t-tmp.drbanki <> "" then t-tmp.drbanki = t-tmp.drbanki + ", ".
      t-tmp.drbanki = t-tmp.drbanki + "  Наим.организации кредитора : " + pkanketh.value1.
    end.

    find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                  and pkanketh.kritcod = "obrdt" no-lock no-error.
    if avail pkanketh and pkanketh.value1 <> "" then do:
      if t-tmp.drbanki <> "" then t-tmp.drbanki = t-tmp.drbanki + ", ".
      t-tmp.drbanki = t-tmp.drbanki + "  Дата возникн.обяз-в  :" + pkanketh.value1.
    end.


    find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                  and pkanketh.kritcod = "obexpdt" no-lock no-error.
    if avail pkanketh and pkanketh.value1 <> "" then do:
      if t-tmp.drbanki <> "" then t-tmp.drbanki = t-tmp.drbanki + ", ".
      t-tmp.drbanki = t-tmp.drbanki + "  Дата прекращ.обяз-в   :" + pkanketh.value1.
    end.

/* Состав семьи */
    find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                  and pkanketh.kritcod = "family" no-lock no-error.

    if avail pkanketh and pkanketh.value1 <> "" then do:
        find first pkkrit where pkkrit.kritcod = pkanketh.kritcod no-lock no-error.

        if avail pkkrit then find bookcod where bookcod.bookcod = pkkrit.kritspr and bookcod.code = pkanketh.value1 no-lock no-error.
        if avail bookcod then t-tmp.family = bookcod.name.
        else do:
          find codfr where codfr.codfr = pkkrit.kritspr and codfr.code = pkanketh.value1 no-lock no-error.
          if avail codfr then t-tmp.family = codfr.name[1].
        end.

        if t-tmp.family <> "" then t-tmp.family = t-tmp.family + ", ".
        t-tmp.family = t-tmp.family + pkanketh.value2.
    end.

    find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln
                  and pkanketh.kritcod = "childin" no-lock no-error.
    if avail pkanketh and pkanketh.value1 <> "" then do:
      if t-tmp.family <> "" then t-tmp.family = t-tmp.family + ", ".
      t-tmp.family = t-tmp.family + " детей : " + pkanketh.value1 .
    end.

   {pkcash.i &param = "londebt.cif matches v-cif"}.
   find first wrk where wrk.lon = v-lon no-lock no-error.

   if avail wrk then t-tmp.days = wrk.dt1.
   if avail wrk then t-tmp.damt = wrk.bal1 + wrk.bal2 + wrk.bal3.

put stream m-out unformatted "<html><head><title>TEXAKABANK</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

       put stream m-out unformatted "<center><h3>Отчет </h3><br> (основные характериcтики выданного займа)<br></center>" skip.

       put stream m-out unformatted "<b>Дата</b> " string(t-tmp.dt, "99.99.9999") "<br><br>" skip.
       put stream m-out unformatted "<b>Ф.И.О. заемщика </b> " t-tmp.fio "<br><br>" skip.
       put stream m-out unformatted "<b>N договора потребительского кредитования </b> " t-tmp.dog "<br><br>" skip.
       put stream m-out unformatted "<b>Сумма кредита  </b> " replace(trim(string(t-tmp.lonamt, "->>>>>>>>>>>>9.99")),".",",")  "<br><br>" skip.
       put stream m-out unformatted "<b>Дата открытия  </b> " string(t-tmp.dt1, "99.99.9999")  "<br><br>" skip.
       put stream m-out unformatted "<b>Дата закрытия  </b> " string(t-tmp.dt2, "99.99.9999")  "<br><br>" skip.

       put stream m-out unformatted "<b>Место работы  </b> " t-tmp.job  "<br><br>" skip.
       put stream m-out unformatted "<b>Место жительства (прописка) </b> " t-tmp.homep  "<br><br>" skip.
       put stream m-out unformatted "<b>Место жительства (фактическое проживание) </b> " t-tmp.homef  "<br><br>" skip.

       put stream m-out unformatted "<b>Наличие недвижимого имущества  </b> " t-tmp.imush  "<br><br>" skip.
       put stream m-out unformatted "<b>Автотранспортное средство  </b> " t-tmp.avto  "<br><br>" skip.
       put stream m-out unformatted "<b>Наличие финансовых требований и обязательств  </b> " t-tmp.drbanki  "<br><br>" skip.

       put stream m-out unformatted "<b>Состав семьи  </b> " t-tmp.family  "<br><br>" skip.

       put stream m-out unformatted "<b>Задолженность </b> " replace(string(t-tmp.damt, ">>>>>>>>>>>9.99"),".",",")  " <b> Дней просрочки  </b> " if t-tmp.days > 0 then string(t-tmp.days) else " "   "<br><br><br>" skip.

       put stream m-out unformatted "<b>Меры воздействия</b> <br> <br>" skip.

       put stream m-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                           style=""border-collapse: collapse"">" skip.

       put stream m-out unformatted "<tr style=""font:bold"" bgcolor=""#C0C0C0"" align=""center"" >"
                         "<td>Дата</td>"
                         "<td>Время</td>"
                         "<td>Кто действ</td>"
                         "<td>Действие</td>"
                         "<td>Результат</td>"
                         "<td>Дата контроля </td>"
                         "<td>Примечания</td>"
                          skip.

        for each pkdebtdat where pkdebtdat.bank = s-ourbank and pkdebtdat.lon = v-lon no-lock.
               put stream m-out  unformatted       "<tr>"
                           "<td>" string(pkdebtdat.rdt,"99.99.9999" ) "</td>"
                           "<td>" string(pkdebtdat.rtim)   "</td>"
                           "<td>" pkdebtdat.rwho   "</td>".

                           find bookcod where bookcod.bookcod = "pkdbtact" and bookcod.code = pkdebtdat.action no-lock no-error.
                           if avail bookcod then
                                  put stream m-out  unformatted "<td>" bookcod.name "</td>" .
                           else
                                  put stream m-out  unformatted "<td>"  "</td>" .

                           find bookcod where bookcod.bookcod = "pkdbtres" and bookcod.code = pkdebtdat.result no-lock no-error.
                           if avail bookcod then
                                  put stream m-out  unformatted "<td>" bookcod.name "</td>" .
                           else
                                  put stream m-out  unformatted "<td>"  "</td>" .

                           put stream m-out  unformatted
                           "<td>" if pkdebtdat.checkdt = ? then "" else string(pkdebtdat.checkdt, "99.99.9999" )   "</td>"
                           "<td>" pkdebtdat.info[1] "</td></tr>"
                           skip.
                           release bookcod.
        end.

        put stream m-out unformatted
                        "</table><br><br>".


       put stream m-out unformatted "<b>Письма </b> <br> <br>" skip.

       put stream m-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0""
                                           style=""border-collapse: collapse"">" skip.

       put stream m-out unformatted "<tr style=""font:bold"" bgcolor=""#C0C0C0"" align=""center"" >"
                         "<td>Дата</td>"
                         "<td>Тип</td>"
                         "<td>Письмо</td>"
                         "<td>Менеджер</td>"
                         "<td>Ведомость</td>"
                          skip.

        for each letters where letters.ref = v-lon no-lock.
               put stream m-out  unformatted       "<tr>"
                           "<td>" string(letters.rdt, "99.99.9999" ) "</td>"
                           "<td>" letters.type         "</td>"
                           "<td>" letters.docnum       "</td>"
                           "<td>" letters.who          "</td>"
                           "<td>" letters.roll         "</td></tr>"
                           skip.
        end.

        put stream m-out unformatted
                        "</table><br><br>".


        put stream m-out unformatted "<b>Повторный запрос ГЦВП           </b> <br><br>" skip.
        put stream m-out unformatted "<b>Запрос о наличии счетов         </b> <br><br>" skip.
        put stream m-out unformatted "<b>Платежные требования поручения  </b> <br><br>" skip.
        put stream m-out unformatted "<b>Погашение задолженности           </b> <br><br>" skip.
        put stream m-out unformatted "<b>Списание за баланс              </b> <br><br>" skip.
        put stream m-out unformatted "<b>Разное                          </b> <br><br>" skip.

output stream m-out close.
unix silent cptwin pkbadmrpo.html excel.
