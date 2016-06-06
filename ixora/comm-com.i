
/* comm-com.i
 * Модуль
     Коммунальные платежи
 * Назначение
     Процедура вывода списка Получателей
 * Применение
     Применяется при приеме платежей, зачилении на АРП, зачисление на счета организации
 * Вызов
     Вызываемый файл
 * Пункты меню

 * Автор
     pragma
 * Дата создания:
     31/12/99 pragma
     27.02.02
 * Изменения
     08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
     22.07.03    kanat Добавил обработку платежей АПК
     16/01/2006  U00568 Evgeniy создал COMM-COM-1 на случай если выбор комиссии будет не только по "7" пункту
                 ТЗ 175 от 16/11/2005 от ДРР
     15.02.2006 u00568 evgeniy - сделал возможным передачу не одного кода в процедуру,
          а нескольких, через #
          в случае если сумма не попадает в вилки сумм тарифов, берется последний тариф.
          в  COMM-COM-1 code стал output, туда передаешь '12#13' а он возвращает код из соответствующей вилки
          в  COMM-COM-1 появился output comchar as char
     28.11.2006 u00568 evgeniy - все тарифы перенес в function get_tarifs_common  (comm-com.i)
*/



/*#####################################################*/
/*###   Выбор названия группы платежей для commonls ###*/
/*###   - в родительном падеже для "Платежи ..."    ###*/
/*#####################################################*/

function selname returns char (v-selgrp as integer).
    case v-selgrp:
         when 1 then return "".
         when 2 then return "".
         when 3 then return "".
         when 4 then return "".
         when 5 then return "ИВЦ".
         when 6 then return "Алсеко".
         when 7 then return "Водоканал".
         when 8 then return "АПК".
         when 9 then return "".
    end case.
end function.


/*##############################################*/
/*###          Выбор группы платежей         ###*/
/*###      возвращает номер из commonls      ###*/
/*##############################################*/
procedure comm-grp.
def output parameter vsgrp as integer.

    run sel('Выберите организацию', 'ИВЦ          |Алсеко       |Водоканал    |АПК          ').

    case return-value:
       when "1" then vsgrp = 5.
       when "2" then vsgrp = 6.
       when "3" then vsgrp = 7.
       when "4" then vsgrp = 8.
       otherwise
                vsgrp = -1.
    end.
end.

/* возвращает группу СПФ - текущего пользователя для определения комиссии*/
/*
function my_grp_of_ppoint returns int ().
  def var i_temp as integer no-undo.
  i_temp = get-dep (userid ("bank"),  today).
  find first ppoint where ppoint.dep =  i_temp_dep no-lock no-error.
  if avail ppoint then do:
    i_temp = ppoint.grp.
  end. else do:
    message "Возможно ваш СПФ снесли." view-as alert-box title "".
    apply "stop".
  end.

  return i_temp.
end function.
*/

function get_tarifs_common returns char (seltxb as int, agpr as int, docrnnbn as char, juridical_person as logical).
  def var grp_of_ppoint as integer no-undo.
  def var doccomcode as char no-undo.
  def var pp as integer no-undo.
  def var lis_it_pens as logical no-undo.

  /*pp = get-dep (userid ("bank"),  today).*/

  /*--- станции диагностики -------------------------------------------------*/
  if agpr = 1 then do:
        case seltxb:
          WHEN 0 then do: /*алматы*/
            /* все остальные */
            doccomcode = "02#22#23".
            if docrnnbn = "600700012225" /*docarp = "000076261"*/  /*Таможенное управление г. Алматы рнн 600700012225*/
                or docrnnbn = "092200000736" /*docarp = "002076162"*/  /* Таможенные платежи */
            then do:
              doccomcode = "29#13".
            end.
            /* Фотосистем */
            /*
            if docarp = "000076575" or docarp = "010904718" or docarp = "010904019" then
              doccomcode = "01".
            */
            if  docrnnbn = "600700212767" /*docarp = "010904103"*/ /* КГП ЦИС */
                or docrnnbn = '090100000352' /*РГП "Центр по недвижимости КРСМЮ"*/
                or docrnnbn = '600700022288' /*РГП "Центр по недвижимости по г. Алматы"*/
            then do:
              doccomcode = "03#04#05".
            end.
            if docrnnbn = '600400511745' then /*фотосистем*/
              doccomcode = "40".
            if docrnnbn = '620300003390' then /* РГП ИПЦ КРС МИН.ЮСТ.Казахстан */
              doccomcode = "40".
            if docrnnbn = '620200266200' then /* ТОО "Digital Format" */
              doccomcode = "40".
          end.

          WHEN 1 then do: /*Астана*/
            doccomcode = "02#22#23".
            if docrnnbn = '620300003390' then /* РГП ИПЦ КРС МИН.ЮСТ.Казахстан */
              doccomcode = "40".
            if docrnnbn = '600400511745' then /*фотосистем*/
              doccomcode = "40".
            if docrnnbn = '620200266200' then /* ТОО "Digital Format" */
              doccomcode = "40".
          end.

          WHEN 2 then do: /*уральск*/
            doccomcode = "43#44#45#46".
            if docrnnbn = '271800000854' /* РКП Спецавтобаза */
                or docrnnbn = '271800003287' /* ОАО Жайыктеплоэнерго  */
                or docrnnbn = '271800003419' /* ОАО Уральскэнерго   */
                or docrnnbn = '270100224053' /* ГКП "Орал Су Арнасы"    */
                or docrnnbn = '270100000064' /* ОАО "Уральскоблгаз"    */
                or docrnnbn = '270100227861' /* ТОО Акжайыкэнергосауда    */
            then
              doccomcode = "10".
            if docrnnbn = '620300003390' then /* РГП ИПЦ КРС МИН.ЮСТ.Казахстан */
              doccomcode = "40".
            if docrnnbn = '600400511745' then /*фотосистем*/
              doccomcode = "40".
            if docrnnbn = '620200266200' then /* ТОО "Digital Format" */
              doccomcode = "40".
          end.

          WHEN 3 then do: /*Атырау*/
            if juridical_person then
              doccomcode = "35#36".
            else
              doccomcode = "18#19#33#34".
            if docrnnbn = '620300003390' then /* РГП ИПЦ КРС МИН.ЮСТ.Казахстан */
              doccomcode = "40".
            if docrnnbn = '600400511745' then /*фотосистем*/
              doccomcode = "40".
            if docrnnbn = '620200266200' then /* ТОО "Digital Format" */
              doccomcode = "40".
          end.

          WHEN 4 then do: /*Актобе*/
            if juridical_person then
              doccomcode = "18#19#33".
            else
              doccomcode = "20#25#28#33".
            if docrnnbn = '620300003390' then /* РГП ИПЦ КРС МИН.ЮСТ.Казахстан */
              doccomcode = "40".
            if docrnnbn = '600400511745' then /*фотосистем*/
              doccomcode = "40".
            if docrnnbn = '620200266200' then /* ТОО "Digital Format" */
              doccomcode = "40".
          end.
          WHEN 5 then
          do:
            /*Караганда*/
            doccomcode = '02#22#23'.
            if docrnnbn = '620300003390' then /* РГП ИПЦ КРС МИН.ЮСТ.Казахстан */
              doccomcode = "40".
            if docrnnbn = '600400511745' then /*фотосистем*/
              doccomcode = "40".
            if docrnnbn = '620200266200' then /* ТОО "Digital Format" */
              doccomcode = "40".
            if  docrnnbn = '301700002316' /*РГП "Центр по недвижимости Караганда"*/
            then
              doccomcode = "03#04#05".
          end.

          WHEN 6 then do: /*Талдыкорган*/
            doccomcode = "02#22#23".
            if docrnnbn = '620300003390' then /* РГП ИПЦ КРС МИН.ЮСТ.Казахстан */
              doccomcode = "40".
            if docrnnbn = '600400511745' then /*фотосистем*/
              doccomcode = "40".
            if docrnnbn = '620200266200' then /* ТОО "Digital Format" */
              doccomcode = "40".
          end.

        end case.
  end.
  /*--- Прочие платежи организаций --------------------------------------------*/
  if agpr = 9 then do:
        doccomcode = "10".
        case seltxb:
          WHEN 0 then do:
              if docrnnbn = '600800034120' or docrnnbn = '600800039693' then
                doccomcode = "11". /*КСК "ЭКО" и КСК "Ернар"*/
          end.
        end.
  end.
  /*--- Казахтелеком --------------------------------------------*/
  if (seltxb <> 1 and agpr = 3)
  or (seltxb =  1 and agpr = 10) then do:
    doccomcode = "17".
  end.

  /*--- Пенсионные платежи И Социальные отчисления --------------------------------------------*/
  if agpr = 15 then do:
    lis_it_pens = docrnnbn = "1".   /*is_it_pens 0 - платежи в ГЦВП, 1 - платежи в пенсионный фонд*/
    if lis_it_pens then
      doccomcode = '09'.
    else
      doccomcode = '27'.
  end.

  /*--- Астана Энергосервис --------------------------------------------*/
  if agpr = 2 then do:
    doccomcode = "10".
  end.
  /*--- Астана энергосбыт --------------------------------------------*/
  if agpr = 3 and seltxb = 1 then do:
    doccomcode = "10".
  end.
  /*--- Kcell, K-Mobile --------------------------------------------*/
  if agpr = 4 then do:
    case seltxb:
      when 0 then doccomcode = "17".
      when 1 then doccomcode = "17".
      when 2 then doccomcode = "17".
      when 3 then doccomcode = "17".
      when 4 then doccomcode = "17".
      when 5 then doccomcode = "17".
      when 6 then doccomcode = "17".
    END CASE.
  end.
  /*--- ИВЦ/Алсеко/Водоканал/АПК --------------------------------------------*/
  if agpr = 5 or agpr = 6 or agpr = 7 or agpr = 8 then do:
    doccomcode = "10".
  end.


  return (doccomcode).

  /*
  grp_of_ppoint = my_grp_of_ppoint().
  find first comm_tarifs where comm_tarifs.grp_ppoint = grp_of_ppoint
                           and comm_tarifs.table_grp = agpr
                           and comm_tarifs.txb = atxb
                           and comm_tarifs.table_name = "commonls"
                           and comm_tarifs.deluid = ?
                           and comm_tarifs.start_date <= adate
                           and (comm_tarifs.end_date = ? or comm_tarifs.end_date >= adate)
                         no-lock no-error.
  if avail comm_tarifs then do:
  return(comm_tarifs.tarifs)
  end else do:
    message "Для данной операции нет работающих тарифов" view-as alert-box title "".
    return('').
  end.
  */
end function.


/* возвращает сумму комиссии
   sum - передаем сумму
   code - код туда передаешь '12#13',
   first_code - серия кода - например 7,
   comchar - название комиссии
   return - получаем сумму комисии.
*/
function COMM-COM-1 returns decimal ( sum as decimal, input-output code as char, first_code as char,  output comchar as char).
  define var trid as rowid.
  define var cods_list as char.
  cods_list = code.
  if sum = 0 then return 0.00.
  REPEAT ON ENDKEY UNDO, RETRY:
    code = entry(1,cods_list,'#') no-error.
    cods_list = substr(cods_list, length(entry(1,cods_list,'#')) + 2, length(cods_list)) no-error.
    if code = '' then do:
      find first tarif2 where rowid(tarif2) = trid or trid = ?  no-lock no-error.
      code = tarif2.kod.
      if tarif2.ost <> 0 then
        return tarif2.ost.
      return sum * tarif2.proc * 0.01.
      leave.
    end.
    find first tarif2 where num = first_code and kod = code
                        and tarif2.stat = 'r' no-lock no-error.
    comchar = tarif2.pakalp.
    trid = rowid(tarif2).
    if can-find(first tarif2 no-lock where num = first_code and pakalp = comchar and
                rowid(tarif2) <> trid and tarif2.stat = 'r')
    then do:
      for each tarif2 no-lock where num = first_code and pakalp = comchar and tarif2.stat = 'r':
        if sum >= tarif2.min and (sum <= tarif2.max or tarif2.max = 0) then do:
          if tarif2.ost <> 0 then
            return tarif2.ost.
          return sum * tarif2.proc * 0.01.
        end.
      end.
    end. else do:
      if sum >= tarif2.min and (sum <= tarif2.max or tarif2.max = 0) then do:
        if tarif2.ost <> 0 then
          return tarif2.ost.
        return sum * tarif2.proc * 0.01.
      end.
    end.
  END.  /* REPEAT  */
end.




/*передаем сумму и код, получаем сумму комисии*/
function COMM-COM returns decimal ( sum as decimal, code as char).
  define var comchar as char.
  return COMM-COM-1 (sum, code, "7", comchar).
end.



/* Вычисление комиссии-------------------------------------------------------*/
define temp-table cms
    field id as char
    field name like tarif2.pakalp
    index name is unique primary name.

procedure comm-coms.

  for each tarif2 where num = "7" and tarif2.stat = 'r' no-lock:
      do transaction on error undo, next:
          create cms.
          cms.name = tarif2.pakalp no-error.
          if error-status:error then undo, next.
          cms.id = tarif2.kod.
      end.
  end.

  def query q1 for cms.

  def browse b1
      query q1 no-lock
      display
          cms.name no-label format 'x(30)'
          with 7 down title "Комиссия".

  def frame fr1
      b1
      with no-labels centered overlay view-as dialog-box.

  on return of b1 in frame fr1 do:
    apply "endkey" to frame fr1.
  end.

  open query q1 for each cms.

  if num-results("q1")=0 then do:
    MESSAGE "Записи не найдены." VIEW-AS ALERT-BOX TITLE "Настройте комиссию".
    return.
  end.

  b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
  ENABLE all with frame fr1.
  apply "value-changed" to b1 in frame fr1.
  WAIT-FOR endkey of frame fr1.

  hide frame fr1.
  return cms.id.

end.
