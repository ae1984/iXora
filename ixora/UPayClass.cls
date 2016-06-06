/* UPayClass.cls
 * MODULE
        Класс документа перевода Unistream
 * DESCRIPTION
        Описание программы
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
        29/08/2012 e.berdibekov
        29/11/2012 e.berdibekov - новые типы документов
 * BASES

 * CHANGES
*/



CLASS UPayClass:
    DEFINE private VARIABLE GlobalVar AS CLASS GlobalClass.
    /*************************************************************************************************************/
    DEF PUBLIC VAR v-path  AS CHAR.                  /*Путь для импорта файлов*/
    DEF PUBLIC VAR v-name  AS CHAR.                  /*Наименование импортированного файла*/

    /*Информация о переводе*/
    DEF PUBLIC VAR UIN AS CHAR.                      /*Номер перевода*/
    DEF PUBLIC VAR TransferStatus AS INT.            /*Статус перевода 2-отправка 5-получение 6-возврат*/
    DEF PUBLIC VAR PayFunds AS DECI.                 /*Сумма перевода в валюте оплаты*/
    DEF PUBLIC VAR PayFundsCRC AS CHAR.              /*Валюта перевода*/
    DEF PUBLIC VAR PayFundsCRCISO AS CHAR.           /*Валюта перевода ISO*/
    DEF PUBLIC VAR Comission AS DECI.	             /*Сумма комиссии в валюте оплаты*/
    DEF PUBLIC VAR ComissionCRC AS CHAR.             /*Валюта комиссии*/
    DEF PUBLIC VAR ComissionCRCISO AS CHAR.          /*Валюта комиссии ISO*/
    DEF PUBLIC VAR PayAmount AS DECI.	             /*Итоговая сумма в валюте оплаты*/
    DEF PUBLIC VAR PayDAmount AS DECI.	             /*Итоговая сумма в валюте оплаты*/
    DEF PUBLIC VAR PayAmountCRC AS CHAR.             /*Валюта итоговой суммы*/
    DEF PUBLIC VAR PaydAmountCRC AS CHAR.             /*Валюта итоговой суммы*/
    DEF PUBLIC VAR PayAmountCRCISO AS CHAR.          /*Валюта итоговой суммы ISO*/
    DEF PUBLIC VAR SenderComission AS DECI.          /*Комиссия агента отправителя*/
    DEF PUBLIC VAR SenderComissionCRC AS CHAR.       /*Валюта комиссии агента отправителя*/
    DEF PUBLIC VAR SenderComissionCRCISO AS CHAR.    /*Валюта комиссии агента отправителя ISO*/
    DEF PUBLIC VAR ReceiverComission AS DECI.        /*Комиссия агента получателя*/
    DEF PUBLIC VAR ReceiverComissionCRC AS CHAR.     /*Валюта комиссии агента получателя*/
    DEF PUBLIC VAR ReceiverComissionCRCISO AS CHAR.  /*Валюта комиссии агента получателя ISO*/
    DEF PUBLIC VAR TransferMessage AS CHAR.          /*Сообщение получателю*/
    DEF PUBLIC VAR DebetPayDocID AS CHAR.            /*Номер кассового документа, по приему перевода*/
    DEF PUBLIC VAR DebetPayDocDate AS CHAR.          /*Дата кассового документа, по приему перевода*/
    DEF PUBLIC VAR CreditPayDocID AS CHAR.           /*Номер кассового документа, по выдаче перевода*/
    DEF PUBLIC VAR CreditPayDocDate AS CHAR.         /*Дата кассового документа, по выдаче перевода*/
    DEF PUBLIC VAR PayerCard AS CHAR.                /*Номер карты отправителя*/
    DEF PUBLIC VAR TransferControl AS CHAR.          /*Контрольный вопрос - ответ*/
    DEF PUBLIC VAR PaymentPurpose AS CHAR.           /*Цель перевода/назначение платежа*/



    /*Информация получателя*/
    DEF PUBLIC VAR ToCountry AS CHAR.               /*Страна получения*/
    DEF PUBLIC VAR ToCountryISO AS CHAR.            /*Страна получения ISO*/
    DEF PUBLIC VAR PayeeFname AS CHAR.              /*Имя*/
    DEF PUBLIC VAR PayeeSname AS CHAR.              /*Фамилия*/
    DEF PUBLIC VAR PayeeMname AS CHAR.              /*Отчество*/
    DEF PUBLIC VAR PayeeIsResident AS INT.          /*Признак резидентности получателя.1 - резидент, 0 - не резидент, Пусто - не указано*/
    /*Документ*/
    DEF PUBLIC VAR PayeeCType AS CHAR.              /*Вид документа */
    DEF PUBLIC VAR PayeeCNumber AS CHAR.            /*Номер документа*/
    DEF PUBLIC VAR PayeeSerialNumber AS CHAR.       /*Серия документа*/
    DEF PUBLIC VAR PayeeIssuer AS CHAR.             /*Орган выдачи документа*/
    DEF PUBLIC VAR PayeeIssueDate AS CHAR.          /*Дата выдачи*/
    DEF PUBLIC VAR PayeeIssueDateDT AS DATE.        /*Дата выдачи*/
    /**/
    DEF PUBLIC VAR PayeePhone AS CHAR.              /*Телефон*/
    DEF PUBLIC VAR PayeeCountry AS CHAR.            /*Гражданство*/
    DEF PUBLIC VAR PayeeCountryISO AS CHAR.         /*Гражданство ISO*/
    DEF PUBLIC VAR PayeeBirthDate AS CHAR.          /*Дата рождения*/
    DEF PUBLIC VAR PayeeBirthCountry AS CHAR. 	    /*ISO код страны рождения*/
    DEF PUBLIC VAR PayeeBirthCity AS CHAR. 	        /*Город рождения*/
    DEF PUBLIC VAR PayeeAddress	AS CHAR.            /*Адрес*/

    DEF PUBLIC VAR PayeeINN AS CHAR.                /*ИИН*/
    DEF PUBLIC VAR PayeeRegAddress AS CHAR.         /*Прописка*/
    DEF PUBLIC VAR PayeeRegCity AS CHAR.            /*Прописка*/
    DEF PUBLIC VAR PayeeRegCountry AS CHAR.         /*Прописка*/

    DEF PUBLIC VAR PayeeKbeKod AS CHAR.             /*КВЕ*/
    DEF PUBLIC VAR PayeeKNP AS CHAR.                /*КНП*/
    DEF PUBLIC VAR PayeeMessage AS CHAR.            /*Отделение банка*/
    DEF PUBLIC VAR PayeeAccount AS CHAR.            /*Счет*/

    /*************************************************************************************************************/
    /*************************************************************************************************************/
    /*************************************************************************************************************/
    /*Информация отправителя*/
    DEF PUBLIC VAR FromCountry AS CHAR.             /*Страна отправления*/
    DEF PUBLIC VAR FromCountryISO AS CHAR.          /*Страна отправления ISO*/
    DEF PUBLIC VAR PayerFname AS CHAR.              /*Имя*/
    DEF PUBLIC VAR PayerSname AS CHAR.              /*Фамилия*/
    DEF PUBLIC VAR PayerMname AS CHAR.              /*Отчество*/
    DEF PUBLIC VAR PayerIsResident AS INT.          /*Признак резидентности отправителя.1 - резидент, 0 - не резидент, Пусто - не указано*/
    /*Документ*/
    DEF PUBLIC VAR PayerCType AS CHAR.              /*Вид документа */
    DEF PUBLIC VAR PayerCNumber AS CHAR.            /*Номер документа*/
    DEF PUBLIC VAR PayerSerialNumber AS CHAR.       /*Серия документа*/
    DEF PUBLIC VAR PayerIssuer AS CHAR.             /*Орган выдачи документа*/
    DEF PUBLIC VAR PayerIssueDate AS CHAR.          /*Дата выдачи*/
    DEF PUBLIC VAR PayerIssueDateDT AS DATE.        /*Дата выдачи*/
    /**/
    DEF PUBLIC VAR PayerPhone AS CHAR.              /*Телефон*/
    DEF PUBLIC VAR PayerCountry AS CHAR.            /*Гражданство*/
    DEF PUBLIC VAR PayerCountryISO AS CHAR.         /*Гражданство ISO*/
    DEF PUBLIC VAR PayerBirthDate AS CHAR.          /*Дата рождения*/
    DEF PUBLIC VAR PayerBirthCountry AS CHAR. 	    /*ISO код страны рождения*/
    DEF PUBLIC VAR PayerBirthCity AS CHAR. 	        /*Город рождения*/
    DEF PUBLIC VAR PayerAddress	AS CHAR.            /*Адрес*/

    DEF PUBLIC VAR PayerINN AS CHAR.                /*ИИН*/
    DEF PUBLIC VAR PayerRegAddress AS CHAR.         /*Прописка*/
    DEF PUBLIC VAR PayerRegCity AS CHAR.            /*Прописка*/
    DEF PUBLIC VAR PayerRegCountry AS CHAR.         /*Прописка*/

    DEF PUBLIC VAR PayerKbeKod AS CHAR.             /*КВЕ*/
    DEF PUBLIC VAR PayerKNP AS CHAR.                /*КНП*/


    DEF PUBLIC VAR PayCRC AS INT.                 /*Валюта перевода*/
    DEF PUBLIC VAR PaydCRC AS INT.                 /*Валюта перевода*/

    DEF PUBLIC VAR sender_country AS CHAR.
    DEF PUBLIC VAR sender_proffession AS CHAR.
    DEF PUBLIC VAR sender_birthPlace AS CHAR.
    DEF PUBLIC VAR sender_state AS CHAR.
    DEF PUBLIC VAR sender_city AS CHAR.
    DEF PUBLIC VAR sender_street AS CHAR.
    DEF PUBLIC VAR sender_house AS CHAR.
    DEF PUBLIC VAR sender_flat AS CHAR.
    DEF PUBLIC VAR sender_zip AS CHAR.
    DEF PUBLIC VAR sender_docexp AS CHAR. /* Срок действия */

    /*Информация получателя*/
    DEF PUBLIC VAR receiver_country AS CHAR.
    DEF PUBLIC VAR receiver_proffession AS CHAR.
    DEF PUBLIC VAR receiver_birthPlace AS CHAR.
    DEF PUBLIC VAR receiver_state AS CHAR.
    DEF PUBLIC VAR receiver_city AS CHAR.
    DEF PUBLIC VAR receiver_street AS CHAR.
    DEF PUBLIC VAR receiver_house AS CHAR.
    DEF PUBLIC VAR receiver_flat AS CHAR.
    DEF PUBLIC VAR receiver_zip AS CHAR.
    DEF PUBLIC VAR receiver_account AS CHAR.
    DEF PUBLIC VAR receiver_docexp AS CHAR. /* Срок действия */



    /*************************************************************************************************************/
    CONSTRUCTOR  public UPayClass( INPUT Val AS CHAR ):
      v-path = "/tmp".
      v-name = "UPay" + Val + ".xml".
      UIN = Val.
      PayerIsResident = 0.
      PayeeIsResident = 0.
    END CONSTRUCTOR.
    /*************************************************************************************************************/
    /*
    DESTRUCTOR public UPayClass():

    END DESTRUCTOR.
    */
    /*************************************************************************************************************/
    METHOD PUBLIC Log CopyDoc():
      def var InFile as char.
      def var v-result as char init "".
      def var a as char.
      InFile = v-path + 'uabs' + UIN + '.xml'.

      input through value ("upay -transfercode " + UIN + " -save " + v-name + " windows-1251"). /* params */
      repeat:
        import a.
        v-result = v-result + a.
      end.

      if v-result <> "" then return false.
      else return true.
      /*
      input through value ("scp Administrator@`askhost`:" + replace(InFile ,"\\","\\\\") + " " + v-name).
      repeat:
        import a.
        v-result = v-result + a.
      end.
      */

      /* Для теста */
      /*
      unix silent value ("scp Administrator@`askhost`:" + replace(InFile ,"\\","\\\\") + " /data/reports/qpay/iabs" + UIN + '.xml').
      */
     /*
     input through
      repeat:
        import a.
        v-result = v-result + a.
      end.
*/
      /*
      if v-result <> "" then return false.
      else do:
          input through value("ssh Administrator@`askhost` del " + replace(InFile ,"\\","\\\\") + " ").
          repeat:
           import a.
           v-result = v-result + a.
          end.
          if v-result <> "" then message "Ошибка удаления временного файла " InFile view-as alert-box.
          return true.
      end.
      */
    END METHOD.
    /*************************************************************************************************************/
    METHOD PUBLIC CHAR RevertStr(INPUT Val AS CHAR):
     def var Res as char.
     def var dd as char.
     def var mm as char.
     def var yy as char.
      yy = entry(1, Val, "-").
      mm = entry(2, Val, "-").
      dd = entry(3, Val, "-").
      Res = dd + "-" + mm + "-" + yy.
     return Res.
    END METHOD.
    /*************************************************************************************************************/
    METHOD PUBLIC CHAR GetTransferStatus():
       case TransferStatus:
         when 2 then do:
           return "Материальная помощь(отправление перевода)".
         end.
         when 5 then do:
           return "Материальная помощь(выплата перевода)".
         end.
         when 6 then do:
           return "Материальная помощь(возврат перевода)".
         end.
         when 7 then do:
           return "Материальная помощь(отмена перевода)".
         end.
         otherwise do:
           return "".
         end.
       end case.
    END METHOD.
    /*************************************************************************************************************/
    METHOD PUBLIC INT GetCRCcode(INPUT Val AS CHAR):
      find first crc where crc.code = Val no-lock no-error.
      if avail crc then return crc.crc.
      else return 0.
    END METHOD.
    /*************************************************************************************************************/
    METHOD PUBLIC CHAR DocType(INPUT Val AS CHAR):
        case Val:
          when "49" then do:
           return "01-Удостов. личности гражданина РК".
          end.
          when "1" then do:
           return "02-Паспорт гражданина РК".
          end.
          when "6" then do:
           return "04-Вид на жительство иностраца в РК".
          end.
          when "22" then do:
           return "03-Паспорт иностранного госуд-ва".
          end.
          when "52" then do:
           return "05-Удостов. лица без гражданства".
          end.
          when "OTHER" then do:
           return "Иные документы".
          end.
          otherwise do:
            return Val.
          end.
        end case.
    END METHOD.

    /*************************************************************************************************************/
    METHOD PUBLIC LOG CheckDoc():
       def var tmp as char.
          PayFundsCRC = ISOtoCRC(PayFundsCRCISO).
          ComissionCRC = ISOtoCRC(ComissionCRCISO).
          PayAmountCRC = ISOtoCRC(PayAmountCRCISO).
          SenderComissionCRC = ISOtoCRC(SenderComissionCRCISO).
          ReceiverComissionCRC = ISOtoCRC(ReceiverComissionCRCISO).

          ToCountry = ISOtoCOUNTRY(ToCountryISO).
          FromCountry = ISOtoCOUNTRY(FromCountryISO).
          PayeeCountry = ISOtoCOUNTRY(PayeeCountryISO).
          PayerCountry = ISOtoCOUNTRY(PayerCountryISO).

          tmp = CAPS(PayerFname).
          PayerSname = entry(1, tmp, " ").
          PayerFname = entry(2, tmp, " ").
          /*PayerMname = entry(3, tmp, " ").*/
          if NUM-ENTRIES(tmp," " ) > 2 then  PayerMname = entry(3, tmp, " "). else PayerMname = "".

          tmp = CAPS(PayeeFname).
          PayeeSname = entry(1, tmp, " ").
          PayeeFname = entry(2, tmp, " ").
          if NUM-ENTRIES(tmp," " ) > 2 then  PayeeMname = entry(3, tmp, " "). else PayeeMname = "".

          PayerCNumber = CAPS(PayerCNumber).
          PayerSerialNumber = CAPS(PayerSerialNumber).
          PayerIssuer = CAPS(PayerIssuer).
          PayerRegAddress = CAPS(PayerRegAddress).
          PayerRegCity = CAPS(PayerRegCity).

          PayeeCNumber = CAPS(PayeeCNumber).
          PayeeSerialNumber = CAPS(PayeeSerialNumber).
          PayeeIssuer = CAPS(PayeeIssuer).
          PayeeRegAddress = CAPS(PayeeRegAddress).
          PayeeRegCity = CAPS(PayeeRegCity).

          if PayerIssueDate <> "" then PayerIssueDateDT = DATE(RevertStr(PayerIssueDate)).
          if PayeeIssueDate <> "" then PayeeIssueDateDT = DATE(RevertStr(PayeeIssueDate)).

          PayerCType = DocType(PayerCType).
          PayeeCType = DocType(PayeeCType).

      if TransferStatus = 1 then TransferStatus = 2.
      if TransferStatus = 4 then TransferStatus = 5.
       if TransferStatus = 2 or TransferStatus = 5 or TransferStatus = 6 then return true.
       else return false.
    END METHOD.
    /*************************************************************************************************************/
    METHOD PUBLIC CHAR ISOtoCRC(INPUT Val AS CHAR):
     def var Ret as char.
        case Val:
            when '004' then do: Ret = 'AFA'. end. /*Афгани*/
            when '008' then do: Ret = 'ALL'. end. /*Лек*/
            when '012' then do: Ret = 'DZD'. end. /*Алжирский динар*/
            when '020' then do: Ret = 'ADP'. end. /*Андорская песета*/
            when '031' then do: Ret = 'AZM'. end. /*Азербайджанский манат*/
            when '032' then do: Ret = 'ARS'. end. /*Аргентинское песо*/
            when '036' then do: Ret = 'AUD'. end. /*Австралийский доллар*/
            when '044' then do: Ret = 'BSD'. end. /*Багамский доллар*/
            when '048' then do: Ret = 'BHD'. end. /*Бахрейнский динар*/
            when '050' then do: Ret = 'BDT'. end. /*Така*/
            when '051' then do: Ret = 'AMD'. end. /*Армянский драм*/
            when '052' then do: Ret = 'BBD'. end. /*Барбадосский доллар*/
            when '060' then do: Ret = 'BMD'. end. /*Бермудский доллар*/
            when '064' then do: Ret = 'BTN'. end. /*Нгултрум*/
            when '068' then do: Ret = 'BOB'. end. /*Боливиано*/
            when '072' then do: Ret = 'BWP'. end. /*Пула*/
            when '084' then do: Ret = 'BZD'. end. /*Белизский доллар*/
            when '090' then do: Ret = 'SBD'. end. /*Доллар Соломоновых островов*/
            when '096' then do: Ret = 'BND'. end. /*Брунейский доллар*/
            when '100' then do: Ret = 'BGL'. end. /*Лев*/
            when '104' then do: Ret = 'MMK'. end. /*Кьят*/
            when '108' then do: Ret = 'BIF'. end. /*Бурундийский франк*/
            when '116' then do: Ret = 'KHR'. end. /*Риель*/
            when '124' then do: Ret = 'CAD'. end. /*Канадский доллар*/
            when '132' then do: Ret = 'CVE'. end. /*Эскудо Кабо-Верде*/
            when '136' then do: Ret = 'KYD'. end. /*Доллар Каймановых островов*/
            when '144' then do: Ret = 'LKR'. end. /*Шри-Ланкийская рупия*/
            when '152' then do: Ret = 'CLP'. end. /*Чилийское песо*/
            when '156' then do: Ret = 'CNY'. end. /*Юань Ренминби*/
            when '170' then do: Ret = 'COP'. end. /*Колумбийское песо*/
            when '174' then do: Ret = 'KMF'. end. /*Франк Коморских островов*/
            when '188' then do: Ret = 'CRC'. end. /*Костариканский колон*/
            when '191' then do: Ret = 'HRK'. end. /*Куна*/
            when '192' then do: Ret = 'CUP'. end. /*Кубинское песо*/
            when '196' then do: Ret = 'CYP'. end. /*Кипрский фунт*/
            when '203' then do: Ret = 'CZK'. end. /*Чешская крона*/
            when '208' then do: Ret = 'DKK'. end. /*Датская крона*/
            when '214' then do: Ret = 'DOP'. end. /*Доминиканское песо*/
            when '222' then do: Ret = 'SVC'. end. /*Сальвадорский колон*/
            when '230' then do: Ret = 'ЕТВ'. end. /*Эфиопский быр*/
            when '232' then do: Ret = 'ERN'. end. /*Накфа*/
            when '233' then do: Ret = 'ЕЕК'. end. /*Крона*/
            when '238' then do: Ret = 'FKP'. end. /*Фунт Фолклендских островов*/
            when '242' then do: Ret = 'FJD'. end. /*Доллар Фиджи*/
            when '262' then do: Ret = 'DJF'. end. /*Франк Джибути*/
            when '270' then do: Ret = 'GMD'. end. /*Даласи*/
            when '288' then do: Ret = 'GHC'. end. /*Седи*/
            when '292' then do: Ret = 'GIP'. end. /*Гибралтарский фунт*/
            when '320' then do: Ret = 'GTQ'. end. /*Кетсаль*/
            when '324' then do: Ret = 'GNF'. end. /*Гвинейский франк*/
            when '328' then do: Ret = 'GYD'. end. /*Гайанский доллар*/
            when '332' then do: Ret = 'HTG'. end. /*Гурд*/
            when '340' then do: Ret = 'HNL'. end. /*Лемпира*/
            when '344' then do: Ret = 'HKD'. end. /*Гонконгский доллар*/
            when '348' then do: Ret = 'HUF'. end. /*Форинт*/
            when '352' then do: Ret = 'ISK'. end. /*Исландская крона*/
            when '356' then do: Ret = 'INR'. end. /*Индийская рупия*/
            when '360' then do: Ret = 'IDR'. end. /*Рупия*/
            when '364' then do: Ret = 'IRR'. end. /*Иранский риал*/
            when '368' then do: Ret = 'IQD'. end. /*Иракский динар*/
            when '376' then do: Ret = 'ILS'. end. /*Новый израильский шекель*/
            when '388' then do: Ret = 'JMD'. end. /*Ямайский доллар*/
            when '392' then do: Ret = 'JPY'. end. /*Йена*/
            when '398' then do: Ret = 'KZT'. end. /*Тенге*/
            when '400' then do: Ret = 'JOD'. end. /*Иорданский динар*/
            when '404' then do: Ret = 'KES'. end. /*Кенийский шиллинг*/
            when '408' then do: Ret = 'KPW'. end. /*Северо-корейская вона*/
            when '410' then do: Ret = 'KRW'. end. /*Вона*/
            when '414' then do: Ret = 'KWD'. end. /*Кувейтский динар*/
            when '417' then do: Ret = 'KGS'. end. /*Сом*/
            when '418' then do: Ret = 'LAK'. end. /*Кип*/
            when '422' then do: Ret = 'LBP'. end. /*Ливанский фунт*/
            when '426' then do: Ret = 'LSL'. end. /*Лоти*/
            when '428' then do: Ret = 'LVL'. end. /*Латвийский лат*/
            when '430' then do: Ret = 'LRD'. end. /*Либерийский доллар*/
            when '434' then do: Ret = 'LYD'. end. /*Ливийский динар*/
            when '440' then do: Ret = 'LTL'. end. /*Литовский лит*/
            when '446' then do: Ret = 'MOP'. end. /*Патака*/
            when '450' then do: Ret = 'MGF'. end. /*Малагасийский франк*/
            when '454' then do: Ret = 'MWK'. end. /*Квача*/
            when '458' then do: Ret = 'MYR'. end. /*Малайзийский ринггит*/
            when '462' then do: Ret = 'MVR'. end. /*Руфия*/
            when '470' then do: Ret = 'MTL'. end. /*Мальтийская лира*/
            when '478' then do: Ret = 'MRO'. end. /*Угия*/
            when '480' then do: Ret = 'MUR'. end. /*Маврикийская рупия*/
            when '484' then do: Ret = 'MXN'. end. /*Мексиканское песо*/
            when '496' then do: Ret = 'MNT'. end. /*Тугрик*/
            when '498' then do: Ret = 'MDL'. end. /*Молдавский лей*/
            when '504' then do: Ret = 'MAD'. end. /*Марокканский дирхам*/
            when '508' then do: Ret = 'MZM'. end. /*Метикал*/
            when '512' then do: Ret = 'OMR'. end. /*Оманский риал*/
            when '516' then do: Ret = 'NAD'. end. /*Доллар Намибии*/
            when '524' then do: Ret = 'NPR'. end. /*Непальская рупия*/
            when '532' then do: Ret = 'ANG'. end. /*Нидерландский гульден*/
            when '533' then do: Ret = 'AWG'. end. /*Арубанский гульден*/
            when '548' then do: Ret = 'VUV'. end. /*Вату*/
            when '554' then do: Ret = 'NZD'. end. /*Новозеландский доллар*/
            when '558' then do: Ret = 'NIO'. end. /*Золотая кордоба*/
            when '566' then do: Ret = 'NGN'. end. /*Найра*/
            when '578' then do: Ret = 'NOK'. end. /*Норвежская крона*/
            when '586' then do: Ret = 'PKR'. end. /*Пакистанская рупия*/
            when '590' then do: Ret = 'PAB'. end. /*Бальбоа*/
            when '598' then do: Ret = 'PGK'. end. /*Кина*/
            when '600' then do: Ret = 'PYG'. end. /*Гуарани*/
            when '604' then do: Ret = 'PEN'. end. /*Новый соль*/
            when '608' then do: Ret = 'PHP'. end. /*Филиппинское песо*/
            when '624' then do: Ret = 'GWP'. end. /*Песо Гвинеи-Бисау*/
            when '626' then do: Ret = 'TPE'. end. /*Тиморское эскудо*/
            when '634' then do: Ret = 'QAR'. end. /*Катарский риал*/
            when '642' then do: Ret = 'ROL'. end. /*Лей*/
            when '643' then do: Ret = 'RUB'. end. /*Российский рубль*/
            when '646' then do: Ret = 'RWF'. end. /*Франк Руанды*/
            when '654' then do: Ret = 'SHP'. end. /*Фунт Острова Святой Елены*/
            when '678' then do: Ret = 'STD'. end. /*Добра*/
            when '682' then do: Ret = 'SAR'. end. /*Саудовский риял*/
            when '690' then do: Ret = 'SCR'. end. /*Сейшельская рупия*/
            when '694' then do: Ret = 'SLL'. end. /*Леоне*/
            when '702' then do: Ret = 'SGD'. end. /*Сингапурский доллар*/
            when '703' then do: Ret = 'SKK'. end. /*Словацкая крона*/
            when '704' then do: Ret = 'VND'. end. /*Донг*/
            when '705' then do: Ret = 'SIT'. end. /*Толар*/
            when '706' then do: Ret = 'SOS'. end. /*Сомалийский шиллинг*/
            when '710' then do: Ret = 'ZAR'. end. /*Рэнд*/
            when '716' then do: Ret = 'ZWD'. end. /*Доллар Зимбабве*/
            when '736' then do: Ret = 'SDD'. end. /*Суданский динар*/
            when '740' then do: Ret = 'SRG'. end. /*Суринамский гульден*/
            when '748' then do: Ret = 'SZL'. end. /*Лилангени*/
            when '752' then do: Ret = 'SEK'. end. /*Шведская крона*/
            when '756' then do: Ret = 'CHF'. end. /*Швейцарский франк*/
            when '760' then do: Ret = 'SYP'. end. /*Сирийский фунт*/
            when '764' then do: Ret = 'THB'. end. /*Бат*/
            when '776' then do: Ret = 'TOP'. end. /*Паанга*/
            when '780' then do: Ret = 'TTD'. end. /*Доллар Тринидада и Тобаго*/
            when '784' then do: Ret = 'AED'. end. /*Дирхам (ОАЭ)*/
            when '788' then do: Ret = 'TND'. end. /*Тунисский динар*/
            when '792' then do: Ret = 'TRL'. end. /*Турецкая лира*/
            when '795' then do: Ret = 'TMM'. end. /*Манат*/
            when '800' then do: Ret = 'UGX'. end. /*Угандийский шиллинг*/
            when '807' then do: Ret = 'MKD'. end. /*Динар*/
            when '810' then do: Ret = 'RUB'. end. /*Российский рубль*/
            when '818' then do: Ret = 'EGP'. end. /*Египетский фунт*/
            when '826' then do: Ret = 'GBP'. end. /*Фунт стерлингов*/
            when '834' then do: Ret = 'TZS'. end. /*Танзанийский шиллинг*/
            when '840' then do: Ret = 'USD'. end. /*Доллар США*/
            when '858' then do: Ret = 'UYU'. end. /*Уругвайское песо*/
            when '860' then do: Ret = 'UZS'. end. /*Узбекский сум*/
            when '862' then do: Ret = 'VEB'. end. /*Боливар*/
            when '882' then do: Ret = 'WST'. end. /*Тала*/
            when '886' then do: Ret = 'YER'. end. /*Йеменский риал*/
            when '891' then do: Ret = 'YUM'. end. /*Югославский динар*/
            when '894' then do: Ret = 'ZMK'. end. /*Квача (замбийская)*/
            when '901' then do: Ret = 'TWD'. end. /*Новый тайваньский доллар*/
            when '950' then do: Ret = 'XAF'. end. /*Франк КФА ВЕАС*/
            when '951' then do: Ret = 'XCD'. end. /*Восточно-карибский доллар*/
            when '952' then do: Ret = 'XOF'. end. /*Франк КФА ВСЕАО*/
            when '953' then do: Ret = 'XPF'. end. /*Франк КФП*/
            when '960' then do: Ret = 'XDR'. end. /*СДР */
            when '972' then do: Ret = 'TJS'. end. /*Сомони*/
            when '973' then do: Ret = 'AOA'. end. /*Кванза*/
            when '974' then do: Ret = 'BYR'. end. /*Белорусский рубль*/
            when '975' then do: Ret = 'BGN'. end. /*Болгарский лев*/
            when '976' then do: Ret = 'CDF'. end. /*Конголезский франк*/
            when '977' then do: Ret = 'ВАМ'. end. /*Конвертируемая марка*/
            when '978' then do: Ret = 'EUR'. end. /*Евро*/
            when '980' then do: Ret = 'UAH'. end. /*Гривна*/
            when '981' then do: Ret = 'OEL'. end. /*Лари*/
            when '985' then do: Ret = 'PLN'. end. /*Злотый*/
            when '986' then do: Ret = 'BRL'. end. /*Бразильский реал*/
            otherwise do: Ret = 'НЕИЗВЕСТНАЯ ВАЛЮТА ' + Val. end.
        end case.
        return Ret.
    END METHOD.
    /*************************************************************************************************************/
    METHOD PUBLIC CHAR ISOtoCOUNTRY(INPUT Val AS CHAR):
        def var Ret as char.
        case Val:
            when "ABH" then do: Ret = "АБХАЗИЯ". end.
            when "AUS" then do: Ret = "АВСТРАЛИЯ". end.
            when "AUT" then do: Ret = "АВСТРИЯ". end.
            when "AZE" then do: Ret = "АЗЕРБАЙДЖАН". end.
            when "ALB" then do: Ret = "АЛБАНИЯ". end.
            when "DZA" then do: Ret = "АЛЖИР". end.
            when "ASM" then do: Ret = "АМЕРИКАНСКОЕ САМОА". end.
            when "AIA" then do: Ret = "АНГИЛЬЯ". end.
            when "AGO" then do: Ret = "АНГОЛА". end.
            when "AND" then do: Ret = "АНДОРРА". end.
            when "ATA" then do: Ret = "АНТАРКТИДА". end.
            when "ATG" then do: Ret = "АНТИГУА И БАРБУДА". end.
            when "ARG" then do: Ret = "АРГЕНТИНА". end.
            when "ARM" then do: Ret = "АРМЕНИЯ". end.
            when "ABW" then do: Ret = "АРУБА". end.
            when "AFG" then do: Ret = "АФГАНИСТАН". end.
            when "BHS" then do: Ret = "БАГАМЫ". end.
            when "BGD" then do: Ret = "БАНГЛАДЕШ". end.
            when "BRB" then do: Ret = "БАРБАДОС". end.
            when "BHR" then do: Ret = "БАХРЕЙН". end.
            when "BLR" then do: Ret = "БЕЛАРУСЬ". end.
            when "BLZ" then do: Ret = "БЕЛИЗ". end.
            when "BEL" then do: Ret = "БЕЛЬГИЯ". end.
            when "BEN" then do: Ret = "БЕНИН". end.
            when "BMU" then do: Ret = "БЕРМУДЫ". end.
            when "BGR" then do: Ret = "БОЛГАРИЯ". end.
            when "BOL" then do: Ret = "БОЛИВИЯ, МНОГОНАЦИОНАЛЬНОЕ ГОСУДАРСТВО". end.
            when "BIH" then do: Ret = "БОСНИЯ И ГЕРЦЕГОВИНА". end.
            when "BWA" then do: Ret = "БОТСВАНА". end.
            when "BRA" then do: Ret = "БРАЗИЛИЯ". end.
            when "IOT" then do: Ret = "БРИТАНСКАЯ ТЕРРИТОРИЯ В ИНДИЙСКОМ ОКЕАНЕ". end.
            when "BRN" then do: Ret = "БРУНЕЙ-ДАРУССАЛАМ". end.
            when "BFA" then do: Ret = "БУРКИНА-ФАСО". end.
            when "BDI" then do: Ret = "БУРУНДИ". end.
            when "BTN" then do: Ret = "БУТАН". end.
            when "VUT" then do: Ret = "ВАНУАТУ". end.
            when "HUN" then do: Ret = "ВЕНГРИЯ". end.
            when "VEN" then do: Ret = "ВЕНЕСУЭЛА БОЛИВАРИАНСКАЯ РЕСПУБЛИКА". end.
            when "VGB" then do: Ret = "ВИРГИНСКИЕ ОСТРОВА, БРИТАНСКИЕ". end.
            when "VIR" then do: Ret = "ВИРГИНСКИЕ ОСТРОВА, США". end.
            when "TLS" then do: Ret = "ТИМОР-ЛЕСТЕ". end.
            when "VNM" then do: Ret = "ВЬЕТНАМ". end.
            when "GAB" then do: Ret = "ГАБОН". end.
            when "HTI" then do: Ret = "ГАИТИ". end.
            when "GUY" then do: Ret = "ГАЙАНА". end.
            when "GMB" then do: Ret = "ГАМБИЯ". end.
            when "GHA" then do: Ret = "ГАНА". end.
            when "GLP" then do: Ret = "ГВАДЕЛУПА". end.
            when "GTM" then do: Ret = "ГВАТЕМАЛА". end.
            when "GIN" then do: Ret = "ГВИНЕЯ". end.
            when "GNB" then do: Ret = "ГВИНЕЯ-БИСАУ". end.
            when "DEU" then do: Ret = "ГЕРМАНИЯ". end.
            when "GGY" then do: Ret = "ГЕРНСИ". end.
            when "GIB" then do: Ret = "ГИБРАЛТАР". end.
            when "HND" then do: Ret = "ГОНДУРАС". end.
            when "HKG" then do: Ret = "ГОНКОНГ". end.
            when "GRD" then do: Ret = "ГРЕНАДА". end.
            when "GRL" then do: Ret = "ГРЕНЛАНДИЯ". end.
            when "GRC" then do: Ret = "ГРЕЦИЯ". end.
            when "GEO" then do: Ret = "ГРУЗИЯ". end.
            when "GUM" then do: Ret = "ГУАМ". end.
            when "DNK" then do: Ret = "ДАНИЯ". end.
            when "JEY" then do: Ret = "ДЖЕРСИ". end.
            when "DJI" then do: Ret = "ДЖИБУТИ". end.
            when "DMA" then do: Ret = "ДОМИНИКА". end.
            when "DOM" then do: Ret = "ДОМИНИКАНСКАЯ РЕСПУБЛИКА". end.
            when "EGY" then do: Ret = "ЕГИПЕТ". end.
            when "ZMB" then do: Ret = "ЗАМБИЯ". end.
            when "ESH" then do: Ret = "ЗАПАДНАЯ САХАРА". end.
            when "ZWE" then do: Ret = "ЗИМБАБВЕ". end.
            when "ISR" then do: Ret = "ИЗРАИЛЬ". end.
            when "IND" then do: Ret = "ИНДИЯ". end.
            when "IDN" then do: Ret = "ИНДОНЕЗИЯ". end.
            when "JOR" then do: Ret = "ИОРДАНИЯ". end.
            when "IRQ" then do: Ret = "ИРАК". end.
            when "IRN" then do: Ret = "ИРАН, ИСЛАМСКАЯ РЕСПУБЛИКА". end.
            when "IRL" then do: Ret = "ИРЛАНДИЯ". end.
            when "ISL" then do: Ret = "ИСЛАНДИЯ". end.
            when "ESP" then do: Ret = "ИСПАНИЯ". end.
            when "ITA" then do: Ret = "ИТАЛИЯ". end.
            when "YEM" then do: Ret = "ЙЕМЕН". end.
            when "CPV" then do: Ret = "КАБО-ВЕРДЕ". end.
            when "KAZ" then do: Ret = "КАЗАХСТАН". end.
            when "KHM" then do: Ret = "КАМБОДЖА". end.
            when "CMR" then do: Ret = "КАМЕРУН". end.
            when "CAN" then do: Ret = "КАНАДА". end.
            when "QAT" then do: Ret = "КАТАР". end.
            when "KEN" then do: Ret = "КЕНИЯ". end.
            when "CYP" then do: Ret = "КИПР". end.
            when "KGZ" then do: Ret = "КИРГИЗИЯ". end.
            when "KIR" then do: Ret = "КИРИБАТИ". end.
            when "CHN" then do: Ret = "КИТАЙ". end.
            when "CCK" then do: Ret = "КОКОСОВЫЕ (КИЛИНГ) ОСТРОВА". end.
            when "COL" then do: Ret = "КОЛУМБИЯ". end.
            when "COM" then do: Ret = "КОМОРЫ". end.
            when "COG" then do: Ret = "КОНГО". end.
            when "COD" then do: Ret = "КОНГО, ДЕМОКРАТИЧЕСКАЯ РЕСПУБЛИКА". end.
            when "PRK" then do: Ret = "КОРЕЯ, НАРОДНО-ДЕМОКРАТИЧЕСКАЯ РЕСПУБЛИКА". end.
            when "KOR" then do: Ret = "КОРЕЯ, РЕСПУБЛИКА". end.
            when "CRI" then do: Ret = "КОСТА-РИКА". end.
            when "CIV" then do: Ret = "КОТ Д\'ИВУАР". end.
            when "CUB" then do: Ret = "КУБА". end.
            when "KWT" then do: Ret = "КУВЕЙТ". end.
            when "LAO" then do: Ret = "ЛАОССКАЯ НАРОДНО-ДЕМОКРАТИЧЕСКАЯ РЕСПУБЛИКА". end.
            when "LVA" then do: Ret = "ЛАТВИЯ". end.
            when "LSO" then do: Ret = "ЛЕСОТО". end.
            when "LBR" then do: Ret = "ЛИБЕРИЯ". end.
            when "LBN" then do: Ret = "ЛИВАН". end.
            when "LBY" then do: Ret = "ЛИВИЙСКАЯ АРАБСКАЯ ДЖАМАХИРИЯ". end.
            when "LTU" then do: Ret = "ЛИТВА". end.
            when "LIE" then do: Ret = "ЛИХТЕНШТЕЙН". end.
            when "LUX" then do: Ret = "ЛЮКСЕМБУРГ". end.
            when "MUS" then do: Ret = "МАВРИКИЙ". end.
            when "MRT" then do: Ret = "МАВРИТАНИЯ". end.
            when "MDG" then do: Ret = "МАДАГАСКАР". end.
            when "MYT" then do: Ret = "МАЙОТТА". end.
            when "MAC" then do: Ret = "МАКАО". end.
            when "MKD" then do: Ret = "РЕСПУБЛИКА МАКЕДОНИЯ". end.
            when "MWI" then do: Ret = "МАЛАВИ". end.
            when "MYS" then do: Ret = "МАЛАЙЗИЯ". end.
            when "MLI" then do: Ret = "МАЛИ". end.
            when "UMI" then do: Ret = "МАЛЫЕ ТИХООКЕАНСКИЕ ОТДАЛЕННЫЕ ОСТРОВА СОЕДИНЕННЫХ ШТАТОВ". end.
            when "MDV" then do: Ret = "МАЛЬДИВЫ". end.
            when "MLT" then do: Ret = "МАЛЬТА". end.
            when "MAR" then do: Ret = "МАРОККО". end.
            when "MTQ" then do: Ret = "МАРТИНИКА". end.
            when "MHL" then do: Ret = "МАРШАЛЛОВЫ ОСТРОВА". end.
            when "MEX" then do: Ret = "МЕКСИКА". end.
            when "FSM" then do: Ret = "МИКРОНЕЗИЯ, ФЕДЕРАТИВНЫЕ ШТАТЫ". end.
            when "MOZ" then do: Ret = "МОЗАМБИК". end.
            when "MDA" then do: Ret = "МОЛДОВА, РЕСПУБЛИКА". end.
            when "MCO" then do: Ret = "МОНАКО". end.
            when "MNG" then do: Ret = "МОНГОЛИЯ". end.
            when "MSR" then do: Ret = "МОНТСЕРРАТ". end.
            when "MMR" then do: Ret = "МЬЯНМА". end.
            when "NAM" then do: Ret = "НАМИБИЯ". end.
            when "NRU" then do: Ret = "НАУРУ". end.
            when "NPL" then do: Ret = "НЕПАЛ". end.
            when "NER" then do: Ret = "НИГЕР". end.
            when "NGA" then do: Ret = "НИГЕРИЯ". end.
            when "ANT" then do: Ret = "НИДЕРЛАНДСКИЕ АНТИЛЫ". end.
            when "NLD" then do: Ret = "НИДЕРЛАНДЫ". end.
            when "NIC" then do: Ret = "НИКАРАГУА". end.
            when "NIU" then do: Ret = "НИУЭ". end.
            when "NZL" then do: Ret = "НОВАЯ ЗЕЛАНДИЯ". end.
            when "NCL" then do: Ret = "НОВАЯ КАЛЕДОНИЯ". end.
            when "NOR" then do: Ret = "НОРВЕГИЯ". end.
            when "ARE" then do: Ret = "ОБЪЕДИНЕННЫЕ АРАБСКИЕ ЭМИРАТЫ". end.
            when "OMN" then do: Ret = "ОМАН". end.
            when "CYM" then do: Ret = "ОСТРОВА КАЙМАН". end.
            when "COK" then do: Ret = "ОСТРОВА КУКА". end.
            when "TCA" then do: Ret = "ОСТРОВА ТЕРКС И КАЙКОС". end.
            when "BVT" then do: Ret = "ОСТРОВ БУВЕ". end.
            when "IMN" then do: Ret = "ОСТРОВ МЭН". end.
            when "NFK" then do: Ret = "ОСТРОВ НОРФОЛК". end.
            when "CXR" then do: Ret = "ОСТРОВ РОЖДЕСТВА". end.
            when "HMD" then do: Ret = "ОСТРОВ ХЕРД И ОСТРОВА МАКДОНАЛЬД". end.
            when "PAK" then do: Ret = "ПАКИСТАН". end.
            when "PLW" then do: Ret = "ПАЛАУ". end.
            when "PSE" then do: Ret = "ПАЛЕСТИНСКАЯ ТЕРРИТОРИЯ, ОККУПИРОВАННАЯ". end.
            when "PAN" then do: Ret = "ПАНАМА". end.
            when "VAT" then do: Ret = "ПАПСКИЙ ПРЕСТОЛ (ГОСУДАРСТВО - ГОРОД ВАТИКАН)". end.
            when "PNG" then do: Ret = "ПАПУА-НОВАЯ ГВИНЕЯ". end.
            when "PRY" then do: Ret = "ПАРАГВАЙ". end.
            when "PER" then do: Ret = "ПЕРУ". end.
            when "PCN" then do: Ret = "ПИТКЕРН". end.
            when "POL" then do: Ret = "ПОЛЬША". end.
            when "PRT" then do: Ret = "ПОРТУГАЛИЯ". end.
            when "PRI" then do: Ret = "ПУЭРТО-РИКО". end.
            when "REU" then do: Ret = "РЕЮНЬОН". end.
            when "RUS" then do: Ret = "РОССИЯ". end.
            when "RWA" then do: Ret = "РУАНДА". end.
            when "ROU" then do: Ret = "РУМЫНИЯ". end.
            when "WSM" then do: Ret = "САМОА". end.
            when "SMR" then do: Ret = "САН-МАРИНО". end.
            when "STP" then do: Ret = "САН-ТОМЕ И ПРИНСИПИ". end.
            when "SAU" then do: Ret = "САУДОВСКАЯ АРАВИЯ". end.
            when "SWZ" then do: Ret = "СВАЗИЛЕНД". end.
            when "SHN" then do: Ret = "СВЯТАЯ ЕЛЕНА". end.
            when "MNP" then do: Ret = "СЕВЕРНЫЕ МАРИАНСКИЕ ОСТРОВА". end.
            when "SYC" then do: Ret = "СЕЙШЕЛЫ". end.
            when "BLM" then do: Ret = "СЕН-БАРТЕЛЕМИ". end.
            when "MAF" then do: Ret = "СЕН-МАРТЕН". end.
            when "SEN" then do: Ret = "СЕНЕГАЛ". end.
            when "VCT" then do: Ret = "СЕНТ-ВИНСЕНТ И ГРЕНАДИНЫ". end.
            when "KNA" then do: Ret = "СЕНТ-КИТС И НЕВИС". end.
            when "LCA" then do: Ret = "СЕНТ-ЛЮСИЯ". end.
            when "SPM" then do: Ret = "СЕНТ-ПЬЕР И МИКЕЛОН". end.
            when "SRB" then do: Ret = "СЕРБИЯ". end.
            when "SGP" then do: Ret = "СИНГАПУР". end.
            when "SYR" then do: Ret = "СИРИЙСКАЯ АРАБСКАЯ РЕСПУБЛИКА". end.
            when "SVK" then do: Ret = "СЛОВАКИЯ". end.
            when "SVN" then do: Ret = "СЛОВЕНИЯ". end.
            when "GBR" then do: Ret = "СОЕДИНЕННОЕ КОРОЛЕВСТВО". end.
            when "USA" then do: Ret = "СОЕДИНЕННЫЕ ШТАТЫ". end.
            when "SLB" then do: Ret = "СОЛОМОНОВЫ ОСТРОВА". end.
            when "SOM" then do: Ret = "СОМАЛИ". end.
            when "SDN" then do: Ret = "СУДАН". end.
            when "SUR" then do: Ret = "СУРИНАМ". end.
            when "SLE" then do: Ret = "СЬЕРРА-ЛЕОНЕ". end.
            when "TJK" then do: Ret = "ТАДЖИКИСТАН". end.
            when "THA" then do: Ret = "ТАИЛАНД". end.
            when "TWN" then do: Ret = "ТАЙВАНЬ (КИТАЙ)". end.
            when "TZA" then do: Ret = "ТАНЗАНИЯ, ОБЪЕДИНЕННАЯ РЕСПУБЛИКА". end.
            when "TGO" then do: Ret = "ТОГО". end.
            when "TKL" then do: Ret = "ТОКЕЛАУ". end.
            when "TON" then do: Ret = "ТОНГА". end.
            when "TTO" then do: Ret = "ТРИНИДАД И ТОБАГО". end.
            when "TUV" then do: Ret = "ТУВАЛУ". end.
            when "TUN" then do: Ret = "ТУНИС". end.
            when "TKM" then do: Ret = "ТУРКМЕНИЯ". end.
            when "TUR" then do: Ret = "ТУРЦИЯ". end.
            when "UGA" then do: Ret = "УГАНДА". end.
            when "UZB" then do: Ret = "УЗБЕКИСТАН". end.
            when "UKR" then do: Ret = "УКРАИНА". end.
            when "WLF" then do: Ret = "УОЛЛИС И ФУТУНА". end.
            when "URY" then do: Ret = "УРУГВАЙ". end.
            when "FRO" then do: Ret = "ФАРЕРСКИЕ ОСТРОВА". end.
            when "FJI" then do: Ret = "ФИДЖИ". end.
            when "PHL" then do: Ret = "ФИЛИППИНЫ". end.
            when "FIN" then do: Ret = "ФИНЛЯНДИЯ". end.
            when "FLK" then do: Ret = "ФОЛКЛЕНДСКИЕ ОСТРОВА (МАЛЬВИНСКИЕ)". end.
            when "FRA" then do: Ret = "ФРАНЦИЯ". end.
            when "GUF" then do: Ret = "ФРАНЦУЗСКАЯ ГВИАНА". end.
            when "PYF" then do: Ret = "ФРАНЦУЗСКАЯ ПОЛИНЕЗИЯ". end.
            when "ATF" then do: Ret = "ФРАНЦУЗСКИЕ ЮЖНЫЕ ТЕРРИТОРИИ". end.
            when "HRV" then do: Ret = "ХОРВАТИЯ". end.
            when "CAF" then do: Ret = "ЦЕНТРАЛЬНО-АФРИКАНСКАЯ РЕСПУБЛИКА". end.
            when "TCD" then do: Ret = "ЧАД". end.
            when "MNE" then do: Ret = "ЧЕРНОГОРИЯ". end.
            when "CZE" then do: Ret = "ЧЕШСКАЯ РЕСПУБЛИКА". end.
            when "CHL" then do: Ret = "ЧИЛИ". end.
            when "CHE" then do: Ret = "ШВЕЙЦАРИЯ". end.
            when "SWE" then do: Ret = "ШВЕЦИЯ". end.
            when "SJM" then do: Ret = "ШПИЦБЕРГЕН И ЯН МАЙЕН". end.
            when "LKA" then do: Ret = "ШРИ-ЛАНКА". end.
            when "ECU" then do: Ret = "ЭКВАДОР". end.
            when "GNQ" then do: Ret = "ЭКВАТОРИАЛЬНАЯ ГВИНЕЯ". end.
            when "ALA" then do: Ret = "ЭЛАНДСКИЕ ОСТРОВА". end.
            when "SLV" then do: Ret = "ЭЛЬ-САЛЬВАДОР". end.
            when "ERI" then do: Ret = "ЭРИТРЕЯ". end.
            when "EST" then do: Ret = "ЭСТОНИЯ". end.
            when "ETH" then do: Ret = "ЭФИОПИЯ". end.
            when "ZAF" then do: Ret = "ЮЖНАЯ АФРИКА". end.
            when "SGS" then do: Ret = "ЮЖНАЯ ДЖОРДЖИЯ И ЮЖНЫЕ САНДВИЧЕВЫ ОСТРОВА". end.
            when "OST" then do: Ret = "ЮЖНАЯ ОСЕТИЯ". end.
            when "JAM" then do: Ret = "ЯМАЙКА". end.
            when "JPN" then do: Ret = "ЯПОНИЯ". end.
            otherwise do: Ret = 'НЕИЗВЕСТНАЯ СТРАНА ' + Val. end.
        end case.
        return Ret.
    END METHOD.
    /*************************************************************************************************************/
    METHOD PUBLIC CHAR GetISO3166(INPUT Val AS CHAR):
        def var Ret as char.
        case Val:
            when "AUS" then Ret = "AU". /*	Австралия	*/
            when "AUT" then Ret = "AT". /*	Австрия	*/
            when "AZE" then Ret = "AZ". /*	Азербайджан	*/
            when "ALB" then Ret = "AL". /*	Албания	*/
            when "DZA" then Ret = "DZ". /*	Алжир	*/
            when "AIA" then Ret = "AI". /*	Ангилья о. (GB)	*/
            when "AGO" then Ret = "AO". /*	Ангола	*/
            when "AND" then Ret = "AD". /*	Андорра	*/
            when "ATA" then Ret = "AQ". /*	Антарктика	*/
            when "ATG" then Ret = "AG". /*	Антигуа и Барбуда	*/
            when "ANT" then Ret = "AN". /*	Антильские о-ва (NL)	*/
            when "ARG" then Ret = "AR". /*	Аргентина	*/
            when "ARM" then Ret = "AM". /*	Армения	*/
            when "ABW" then Ret = "AW". /*	Аруба	*/
            when "AFG" then Ret = "AF". /*	Афганистан	*/
            when "BHS" then Ret = "BS". /*	Багамы	*/
            when "BGD" then Ret = "BD". /*	Бангладеш	*/
            when "BRB" then Ret = "BB". /*	Барбадос	*/
            when "BHR" then Ret = "BH". /*	Бахрейн	*/
            when "BLR" then Ret = "BY". /*	Беларусь	*/
            when "BLZ" then Ret = "BZ". /*	Белиз	*/
            when "BEL" then Ret = "BE". /*	Бельгия	*/
            when "BEN" then Ret = "BJ". /*	Бенин	*/
            when "BMU" then Ret = "BM". /*	Бермуды	*/
            when "BVT" then Ret = "BV". /*	Бове о. (NO)	*/
            when "BGR" then Ret = "BG". /*	Болгария	*/
            when "BOL" then Ret = "BO". /*	Боливия	*/
            when "BIH" then Ret = "BA". /*	Босния и Герцеговина	*/
            when "BWA" then Ret = "BW". /*	Ботсвана	*/
            when "BRA" then Ret = "BR". /*	Бразилия	*/
            when "BRN" then Ret = "BN". /*	Бруней Дарассалам	*/
            when "BFA" then Ret = "BF". /*	Буркина-Фасо	*/
            when "BDI" then Ret = "BI". /*	Бурунди	*/
            when "BTN" then Ret = "BT". /*	Бутан	*/
            when "VUT" then Ret = "VU". /*	Вануату	*/
            when "VAT" then Ret = "VA". /*	Ватикан	*/
            when "GBR" then Ret = "GB". /*	Великобритания	*/
            when "HUN" then Ret = "HU". /*	Венгрия	*/
            when "VEN" then Ret = "VE". /*	Венесуэла	*/
            when "VGB" then Ret = "VG". /*	Виргинские о-ва (GB)	*/
            when "VIR" then Ret = "VI". /*	Виргинские о-ва (US)	*/
            when "ASM" then Ret = "AS". /*	Восточное Самоа (US)	*/
            when "TMP" then Ret = "TP". /*	Восточный Тимор	*/
            when "VNM" then Ret = "VN". /*	Вьетнам	*/
            when "GAB" then Ret = "GA". /*	Габон	*/
            when "HTI" then Ret = "HT". /*	Гаити	*/
            when "GUY" then Ret = "GY". /*	Гайана	*/
            when "GMB" then Ret = "GM". /*	Гамбия	*/
            when "GHA" then Ret = "GH". /*	Гана	*/
            when "GLP" then Ret = "GP". /*	Гваделупа	*/
            when "GTM" then Ret = "GT". /*	Гватемала	*/
            when "GIN" then Ret = "GN". /*	Гвинея	*/
            when "GNB" then Ret = "GW". /*	Гвинея-Бисау	*/
            when "DEU" then Ret = "DE". /*	Германия	*/
            when "GIB" then Ret = "GI". /*	Гибралтар	*/
            when "HND" then Ret = "HN". /*	Гондурас	*/
            when "HKG" then Ret = "HK". /*	Гонконг (CN)	*/
            when "GRD" then Ret = "GD". /*	Гренада	*/
            when "GRL" then Ret = "GL". /*	Гренландия (DK)	*/
            when "GRC" then Ret = "GR". /*	Греция	*/
            when "GEO" then Ret = "GE". /*	Грузия	*/
            when "GUM" then Ret = "GU". /*	Гуам	*/
            when "DNK" then Ret = "DK". /*	Дания	*/
            when "COD" then Ret = "CD". /*	Демократическая Республика Конго	*/
            when "DJI" then Ret = "DJ". /*	Джибути	*/
            when "DMA" then Ret = "DM". /*	Доминика	*/
            when "DOM" then Ret = "DO". /*	Доминиканская Республика	*/
            when "EGY" then Ret = "EG". /*	Египет	*/
            when "ZMB" then Ret = "ZM". /*	Замбия	*/
            when "ESH" then Ret = "EH". /*	Западная Сахара	*/
            when "ZWE" then Ret = "ZW". /*	Зимбабве	*/
            when "ISR" then Ret = "IL". /*	Израиль	*/
            when "IND" then Ret = "IN". /*	Индия	*/
            when "IDN" then Ret = "ID". /*	Индонезия	*/
            when "JOR" then Ret = "JO". /*	Иордания	*/
            when "IRQ" then Ret = "IQ". /*	Ирак	*/
            when "IRN" then Ret = "IR". /*	Иран	*/
            when "IRL" then Ret = "IE". /*	Ирландия	*/
            when "ISL" then Ret = "IS". /*	Исландия	*/
            when "ESP" then Ret = "ES". /*	Испания	*/
            when "ITA" then Ret = "IT". /*	Италия	*/
            when "YEM" then Ret = "YE". /*	Йемен	*/
            when "CPV" then Ret = "CV". /*	Кабо-Верде	*/
            when "KAZ" then Ret = "KZ". /*	Казахстан	*/
            when "CYM" then Ret = "KY". /*	Каймановы о-ва (GB)	*/
            when "KHM" then Ret = "KH". /*	Камбоджа	*/
            when "CMR" then Ret = "CM". /*	Камерун	*/
            when "CAN" then Ret = "CA". /*	Канада	*/
            when "QAT" then Ret = "QA". /*	Катар	*/
            when "KEN" then Ret = "KE". /*	Кения	*/
            when "CYP" then Ret = "CY". /*	Кипр	*/
            when "KGZ" then Ret = "KG". /*	Киргизстан	*/
            when "KIR" then Ret = "KI". /*	Кирибати	*/
            when "CHN" then Ret = "CN". /*	Китай	*/
            when "CCK" then Ret = "CC". /*	Кокосовые (Киилинг) о-ва (AU)	*/
            when "COL" then Ret = "CO". /*	Колумбия	*/
            when "COM" then Ret = "KM". /*	Коморские о-ва	*/
            when "COG" then Ret = "CG". /*	Конго	*/
            when "CRI" then Ret = "CR". /*	Коста-Рика	*/
            when "CIV" then Ret = "CI". /*	Кот-д'Ивуар	*/
            when "CUB" then Ret = "CU". /*	Куба	*/
            when "KWT" then Ret = "KW". /*	Кувейт	*/
            when "COK" then Ret = "CK". /*	Кука о-ва (NZ)	*/
            when "LAO" then Ret = "LA". /*	Лаос	*/
            when "LVA" then Ret = "LV". /*	Латвия	*/
            when "LSO" then Ret = "LS". /*	Лесото	*/
            when "LBR" then Ret = "LR". /*	Либерия	*/
            when "LBN" then Ret = "LB". /*	Ливан	*/
            when "LBY" then Ret = "LY". /*	Ливия	*/
            when "LTU" then Ret = "LT". /*	Литва	*/
            when "LIE" then Ret = "LI". /*	Лихтенштейн	*/
            when "LUX" then Ret = "LU". /*	Люксембург	*/
            when "MUS" then Ret = "MU". /*	Маврикий	*/
            when "MRT" then Ret = "MR". /*	Мавритания	*/
            when "MDG" then Ret = "MG". /*	Мадагаскар	*/
            when "MYT" then Ret = "YT". /*	Майотта о. (KM)	*/
            when "MAC" then Ret = "MO". /*	Макао (PT)	*/
            when "MKD" then Ret = "MK". /*	Македония	*/
            when "MWI" then Ret = "MW". /*	Малави	*/
            when "MYS" then Ret = "MY". /*	Малайзия	*/
            when "MLI" then Ret = "ML". /*	Мали	*/
            when "MDV" then Ret = "MV". /*	Мальдивы	*/
            when "MLT" then Ret = "MT". /*	Мальта	*/
            when "MAR" then Ret = "MA". /*	Марокко	*/
            when "MTQ" then Ret = "MQ". /*	Мартиника	*/
            when "MHL" then Ret = "MH". /*	Маршалловы о-ва	*/
            when "MEX" then Ret = "MX". /*	Мексика	*/
            when "FSM" then Ret = "FM". /*	Микронезия (US)	*/
            when "MOZ" then Ret = "MZ". /*	Мозамбик	*/
            when "MDA" then Ret = "MD". /*	Молдова	*/
            when "MCO" then Ret = "MC". /*	Монако	*/
            when "MNG" then Ret = "MN". /*	Монголия	*/
            when "MSR" then Ret = "MS". /*	Монсеррат о. (GB)	*/
            when "MMR" then Ret = "MM". /*	Мьянма	*/
            when "NAM" then Ret = "NA". /*	Намибия	*/
            when "NRU" then Ret = "NR". /*	Науру	*/
            when "NPL" then Ret = "NP". /*	Непал	*/
            when "NER" then Ret = "NE". /*	Нигер	*/
            when "NGA" then Ret = "NG". /*	Нигерия	*/
            when "NLD" then Ret = "NL". /*	Нидерланды	*/
            when "NIC" then Ret = "NI". /*	Никарагуа	*/
            when "NIU" then Ret = "NU". /*	Ниуэ о. (NZ)	*/
            when "NZL" then Ret = "NZ". /*	Новая Зеландия	*/
            when "NCL" then Ret = "NC". /*	Новая Каледония о. (FR)	*/
            when "NOR" then Ret = "NO". /*	Норвегия	*/
            when "NFK" then Ret = "NF". /*	Норфолк о. (AU)	*/
            when "ARE" then Ret = "AE". /*	Объединенные Арабские Эмираты	*/
            when "OMN" then Ret = "OM". /*	Оман	*/
            when "PAK" then Ret = "PK". /*	Пакистан	*/
            when "PLW" then Ret = "PW". /*	Палау (US)	*/
            when "PAN" then Ret = "PA". /*	Панама	*/
            when "PNG" then Ret = "PG". /*	Папуа-Новая Гвинея	*/
            when "PRY" then Ret = "PY". /*	Парагвай	*/
            when "PER" then Ret = "PE". /*	Перу	*/
            when "PCN" then Ret = "PN". /*	Питкэрн о-ва (GB)	*/
            when "POL" then Ret = "PL". /*	Польша	*/
            when "PRT" then Ret = "PT". /*	Португалия	*/
            when "PRI" then Ret = "PR". /*	Пуэрто-Рико (US)	*/
            when "REU" then Ret = "RE". /*	Реюньон о. (FR)	*/
            when "CXR" then Ret = "CX". /*	Рождества о. (AU)	*/
            when "RUS" then Ret = "RU". /*	Россия	*/
            when "RWA" then Ret = "RW". /*	Руанда	*/
            when "ROM" then Ret = "RO". /*	Румыния	*/
            when "SLV" then Ret = "SV". /*	Сальвадор	*/
            when "WSM" then Ret = "WS". /*	Самоа	*/
            when "SMR" then Ret = "SM". /*	Сан Марино	*/
            when "STP" then Ret = "ST". /*	Сан-Томе и Принсипи	*/
            when "SAU" then Ret = "SA". /*	Саудовская Аравия	*/
            when "SWZ" then Ret = "SZ". /*	Свазиленд	*/
            when "SJM" then Ret = "SJ". /*	Свалбард и Ян Мейен о-ва (NO)	*/
            when "SHN" then Ret = "SH". /*	Святой Елены о. (GB)	*/
            when "PRK" then Ret = "KP". /*	Северная Корея (КНДР)	*/
            when "MNP" then Ret = "MP". /*	Северные Марианские о-ва (US)	*/
            when "SYC" then Ret = "SC". /*	Сейшелы	*/
            when "VCT" then Ret = "VC". /*	Сен-Винсент и Гренадины	*/
            when "SPM" then Ret = "PM". /*	Сен-Пьер и Микелон (FR)	*/
            when "SEN" then Ret = "SN". /*	Сенегал	*/
            when "KNA" then Ret = "KN". /*	Сент-Кристофер и Невис	*/
            when "LCA" then Ret = "LC". /*	Сент-Люсия	*/
            when "SGP" then Ret = "SG". /*	Сингапур	*/
            when "SYR" then Ret = "SY". /*	Сирия	*/
            when "SVK" then Ret = "SK". /*	Словакия	*/
            when "SVN" then Ret = "SI". /*	Словения	*/
            when "USA" then Ret = "US". /*	Соединенные Штаты Америки	*/
            when "SLB" then Ret = "SB". /*	Соломоновы о-ва	*/
            when "SOM" then Ret = "SO". /*	Сомали	*/
            when "SDN" then Ret = "SD". /*	Судан	*/
            when "SUR" then Ret = "SR". /*	Суринам	*/
            when "SLE" then Ret = "SL". /*	Сьерра-Леоне	*/
            when "TJK" then Ret = "TJ". /*	Таджикистан	*/
            when "THA" then Ret = "TH". /*	Таиланд	*/
            when "TWN" then Ret = "TW". /*	Тайвань	*/
            when "TZA" then Ret = "TZ". /*	Танзания	*/
            when "TCA" then Ret = "TC". /*	Теркс и Кайкос о-ва (GB)	*/
            when "TGO" then Ret = "TG". /*	Того	*/
            when "TKL" then Ret = "TK". /*	Токелау о-ва (NZ)	*/
            when "TON" then Ret = "TO". /*	Тонга	*/
            when "TTO" then Ret = "TT". /*	Тринидад и Тобаго	*/
            when "TUV" then Ret = "TV". /*	Тувалу	*/
            when "TUN" then Ret = "TN". /*	Тунис	*/
            when "TKM" then Ret = "TM". /*	Туркменистан	*/
            when "TUR" then Ret = "TR". /*	Турция	*/
            when "UGA" then Ret = "UG". /*	Уганда	*/
            when "UZB" then Ret = "UZ". /*	Узбекистан	*/
            when "UKR" then Ret = "UA". /*	Украина	*/
            when "WLF" then Ret = "WF". /*	Уоллис и Футуна о-ва (FR)	*/
            when "URY" then Ret = "UY". /*	Уругвай	*/
            when "FRO" then Ret = "FO". /*	Фарерские о-ва (DK)	*/
            when "FJI" then Ret = "FJ". /*	Фиджи	*/
            when "PHL" then Ret = "PH". /*	Филиппины	*/
            when "FIN" then Ret = "FI". /*	Финляндия	*/
            when "FLK" then Ret = "FK". /*	Фолклендские (Мальвинские) о-ва (GB/AR)	*/
            when "FRA" then Ret = "FR". /*	Франция	*/
            when "GUF" then Ret = "GF". /*	Французская Гвиана (FR)	*/
            when "PYF" then Ret = "PF". /*	Французская Полинезия	*/
            when "HMD" then Ret = "HM". /*	Херд и Макдональд о-ва (AU)	*/
            when "HRV" then Ret = "HR". /*	Хорватия	*/
            when "CAF" then Ret = "CF". /*	Центрально-африканская Республика	*/
            when "TCD" then Ret = "TD". /*	Чад	*/
            when "CZE" then Ret = "CZ". /*	Чехия	*/
            when "CHL" then Ret = "CL". /*	Чили	*/
            when "CHE" then Ret = "CH". /*	Швейцария	*/
            when "SWE" then Ret = "SE". /*	Швеция	*/
            when "LKA" then Ret = "LK". /*	Шри-Ланка	*/
            when "ECU" then Ret = "EC". /*	Эквадор	*/
            when "GNQ" then Ret = "GQ". /*	Экваториальная Гвинея	*/
            when "ERI" then Ret = "ER". /*	Эритрия	*/
            when "EST" then Ret = "EE". /*	Эстония	*/
            when "ETH" then Ret = "ET". /*	Эфиопия	*/
            when "YUG" then Ret = "YU". /*	Югославия	*/
            when "ZAF" then Ret = "ZA". /*	Южная Африка	*/
            when "SGS" then Ret = "GS". /*	Южная Георгия и Южные Сандвичевы о-ва	*/
            when "KOR" then Ret = "KR". /*	Южная Корея (Республика Корея)	*/
            when "JAM" then Ret = "JM". /*	Ямайка	*/
            when "JPN" then Ret = "JP". /*	Япония	*/
            when "ATF" then Ret = "TF". /*	? (FR)	*/
            when "IOT" then Ret = "IO". /*	? (GB)	*/
            when "UMI" then Ret = "UM". /*	? (US)	*/
           otherwise do: Ret = 'НЕИЗВЕСТНАЯ СТРАНА ' + Val. end.
        end case.
        return Ret.
    END METHOD.
    /*************************************************************************************************************/


    METHOD PUBLIC CHAR IdToCurrency(INPUT Val AS CHAR):
     def var Ret as char.
        case Val:
                when "1" then do: Ret = "RUB". end.
                when "2" then do: Ret = "USD". end.
                when "3" then do: Ret = "EUR". end.
                when "4" then do: Ret = "BYR". end.
                when "5" then do: Ret = "GBP". end.
                when "6" then do: Ret = "UAH". end.
                when "7" then do: Ret = "LVL". end.
                when "8" then do: Ret = "MDL". end.
                when "9" then do: Ret = "JPY". end.
                when "10" then do: Ret = "KGS". end.
                when "14" then do: Ret = "PHP". end.
                when "15" then do: Ret = "AMD". end.
                when "17" then do: Ret = "CYP". end.
                when "19" then do: Ret = "ARS". end.
                when "20" then do: Ret = "BGN". end.
                when "21" then do: Ret = "CAD". end.
                when "22" then do: Ret = "GHC". end.
                when "23" then do: Ret = "XAF". end.
                when "24" then do: Ret = "CLP". end.
                when "26" then do: Ret = "COP". end.
                when "27" then do: Ret = "MAD". end.
                when "28" then do: Ret = "CHF". end.
                when "29" then do: Ret = "UYU". end.
                when "30" then do: Ret = "PLN". end.
                when "31" then do: Ret = "VEB". end.
                when "32" then do: Ret = "BRL". end.
                when "33" then do: Ret = "BIF". end.
                when "37" then do: Ret = "XOF". end.
                when "38" then do: Ret = "NIO". end.
                when "39" then do: Ret = "DOP". end.
                when "41" then do: Ret = "PYG". end.
                when "42" then do: Ret = "GTQ". end.
                when "43" then do: Ret = "GNF". end.
                when "44" then do: Ret = "HNL". end.
                when "45" then do: Ret = "SLL". end.
                when "46" then do: Ret = "MRO". end.
                when "47" then do: Ret = "MXN". end.
                when "48" then do: Ret = "NGN". end.
                when "49" then do: Ret = "PKR". end.
                when "50" then do: Ret = "RWF". end.
                when "52" then do: Ret = "AUD". end.
                when "53" then do: Ret = "BBD". end.
                when "54" then do: Ret = "CRC". end.
                when "55" then do: Ret = "CVE". end.
                when "56" then do: Ret = "DZD". end.
                when "57" then do: Ret = "FJD". end.
                when "58" then do: Ret = "GMD". end.
                when "59" then do: Ret = "GYD". end.
                when "60" then do: Ret = "INR". end.
                when "61" then do: Ret = "JMD". end.
                when "62" then do: Ret = "KES". end.
                when "63" then do: Ret = "NPR". end.
                when "64" then do: Ret = "TND". end.
                when "66" then do: Ret = "TOP". end.
                when "67" then do: Ret = "TTD". end.
                when "69" then do: Ret = "VND". end.
                when "70" then do: Ret = "WST". end.
                when "72" then do: Ret = "XCD". end.
                when "73" then do: Ret = "AED". end.
                when "74" then do: Ret = "ALL". end.
                when "75" then do: Ret = "BDT". end.
                when "76" then do: Ret = "NZD". end.
                when "77" then do: Ret = "CFA". end.
                when "79" then do: Ret = "MXP". end.
                when "80" then do: Ret = "ILS". end.
                when "81" then do: Ret = "TRY". end.
                when "82" then do: Ret = "CZK". end.
                when "83" then do: Ret = "CNY". end.
                when "84" then do: Ret = "IDR". end.
                when "85" then do: Ret = "LKR". end.
                when "86" then do: Ret = "SYP". end.
                when "87" then do: Ret = "TJS". end.
                when "88" then do: Ret = "BHD". end.
                when "89" then do: Ret = "HKD". end.
                when "90" then do: Ret = "KWD". end.
                when "91" then do: Ret = "QAR". end.
                when "92" then do: Ret = "YER". end.
                when "93" then do: Ret = "EGP". end.
                when "95" then do: Ret = "SAR". end.
                when "96" then do: Ret = "ETB". end.
                when "97" then do: Ret = "KZT". end.
            otherwise do: Ret = 'НЕИЗВЕСТНАЯ ВАЛЮТА ' + Val. end.
        end case.
        return Ret.
    END METHOD.
    /*************************************************************************************************************/

    METHOD PUBLIC CHAR CodeToCountry(INPUT Val AS CHAR):
     def var Ret as char.
        case Val:
             when "004" then do: Ret = "АФГАНИСТАН". end.
             when "008" then do: Ret = "АЛБАНИЯ". end.
             when "012" then do: Ret = "АЛЖИР". end.
             when "020" then do: Ret = "АНДОРРА". end.
             when "024" then do: Ret = "АНГОЛА". end.
             when "028" then do: Ret = "АНТИГУА И БАРБУДА". end.
             when "031" then do: Ret = "АЗЕРБАЙДЖАН". end.
             when "032" then do: Ret = "АРГЕНТИНА". end.
             when "036" then do: Ret = "АВСТРАЛИЯ". end.
             when "040" then do: Ret = "АВСТРИЯ". end.
             when "044" then do: Ret = "БАГАМЫ". end.
             when "048" then do: Ret = "БАХРЕЙН". end.
             when "050" then do: Ret = "БАНГЛАДЕШ". end.
             when "051" then do: Ret = "АРМЕНИЯ". end.
             when "052" then do: Ret = "БАРБАДОС". end.
             when "056" then do: Ret = "БЕЛЬГИЯ". end.
             when "064" then do: Ret = "БУТАН". end.
             when "068" then do: Ret = "БОЛИВИЯ". end.
             when "070" then do: Ret = "БОСНИЯ И ГЕРЦЕГОВИНА". end.
             when "072" then do: Ret = "БОТСВАНА". end.
             when "076" then do: Ret = "БРАЗИЛИЯ". end.
             when "084" then do: Ret = "БЕЛИЗ". end.
             when "090" then do: Ret = "СОЛОМОНОВЫ ОСТРОВА". end.
             when "096" then do: Ret = "БРУНЕЙ". end.
             when "100" then do: Ret = "БОЛГАРИЯ". end.
             when "104" then do: Ret = "МЬЯНМА". end.
             when "108" then do: Ret = "БУРУНДИ". end.
             when "112" then do: Ret = "БЕЛАРУСЬ". end.
             when "116" then do: Ret = "КОРОЛЕВСТВО КАМБОДЖА". end.
             when "120" then do: Ret = "КАМЕРУН". end.
             when "124" then do: Ret = "КАНАДА". end.
             when "132" then do: Ret = "КАБО-ВЕРДЕ". end.
             when "136" then do: Ret = "КАЙМАНОВЫ О-ВА ". end.
             when "140" then do: Ret = "ЦАР". end.
             when "144" then do: Ret = "ШРИ-ЛАНКА". end.
             when "148" then do: Ret = "ЧАД". end.
             when "152" then do: Ret = "ЧИЛИ". end.
             when "156" then do: Ret = "КИТАЙ". end.
             when "170" then do: Ret = "КОЛУМБИЯ". end.
             when "174" then do: Ret = "КОМОРЫ". end.
             when "178" then do: Ret = "КОНГО". end.
             when "180" then do: Ret = "ДЕМОКРАТИЧЕСКАЯ РЕСПУБЛИКА КОНГО". end.
             when "184" then do: Ret = "КУКА О-ВА". end.
             when "188" then do: Ret = "КОСТА-РИКА". end.
             when "191" then do: Ret = "ХОРВАТИЯ". end.
             when "192" then do: Ret = "КУБА". end.
             when "196" then do: Ret = "КИПР". end.
             when "203" then do: Ret = "ЧЕХИЯ". end.
             when "204" then do: Ret = "БЕНИН". end.
             when "208" then do: Ret = "ДАНИЯ". end.
             when "214" then do: Ret = "ДОМИНИКАНСКАЯ РЕСПУБЛИКА". end.
             when "218" then do: Ret = "ЭКВАДОР". end.
             when "222" then do: Ret = "САЛЬВАДОР". end.
             when "226" then do: Ret = "ЭКВАТОРИАЛЬНАЯ ГВИНЕЯ". end.
             when "231" then do: Ret = "ЭФИОПИЯ". end.
             when "232" then do: Ret = "ЭРИТРЕЯ". end.
             when "233" then do: Ret = "ЭСТОНИЯ". end.
             when "242" then do: Ret = "ФИДЖИ". end.
             when "246" then do: Ret = "ФИНЛЯНДИЯ". end.
             when "250" then do: Ret = "ФРАНЦИЯ". end.
             when "262" then do: Ret = "ДЖИБУТИ". end.
             when "266" then do: Ret = "ГАБОН". end.
             when "268" then do: Ret = "ГРУЗИЯ". end.
             when "270" then do: Ret = "ГАМБИЯ". end.
             when "275" then do: Ret = "ПАЛЕСТИНА". end.
             when "276" then do: Ret = "ГЕРМАНИЯ". end.
             when "288" then do: Ret = "ГАНА". end.
             when "296" then do: Ret = "КИРИБАТИ". end.
             when "300" then do: Ret = "ГРЕЦИЯ". end.
             when "308" then do: Ret = "ГРЕНАДА". end.
             when "320" then do: Ret = "ГВАТЕМАЛА". end.
             when "324" then do: Ret = "ГВИНЕЯ". end.
             when "328" then do: Ret = "ГАЙАНА". end.
             when "332" then do: Ret = "ГАИТИ". end.
             when "336" then do: Ret = "ВАТИКАН". end.
             when "340" then do: Ret = "ГОНДУРАС". end.
             when "344" then do: Ret = "ГОНКОНГ". end.
             when "348" then do: Ret = "ВЕНГРИЯ". end.
             when "352" then do: Ret = "ИСЛАНДИЯ". end.
             when "356" then do: Ret = "ИНДИЯ". end.
             when "360" then do: Ret = "ИНДОНЕЗИЯ". end.
             when "364" then do: Ret = "ИРАН". end.
             when "368" then do: Ret = "ИРАК". end.
             when "372" then do: Ret = "ИРЛАНДИЯ". end.
             when "376" then do: Ret = "ИЗРАИЛЬ". end.
             when "380" then do: Ret = "ИТАЛИЯ". end.
             when "384" then do: Ret = "КОТ-Д'ИВУАР". end.
             when "388" then do: Ret = "ЯМАЙКА". end.
             when "392" then do: Ret = "ЯПОНИЯ". end.
             when "398" then do: Ret = "КАЗАХСТАН". end.
             when "400" then do: Ret = "ИОРДАНИЯ". end.
             when "404" then do: Ret = "КЕНИЯ". end.
             when "408" then do: Ret = "КНДР". end.
             when "410" then do: Ret = "ЮЖНАЯ КОРЕЯ". end.
             when "414" then do: Ret = "КУВЕЙТ". end.
             when "417" then do: Ret = "КЫРГЫЗСТАН". end.
             when "418" then do: Ret = "ЛАОССКАЯ НАРОДНО-ДЕМОКРАТИЧЕСКАЯ РЕСПУБЛИКА". end.
             when "422" then do: Ret = "ЛИВАН". end.
             when "426" then do: Ret = "ЛЕСОТО". end.
             when "428" then do: Ret = "ЛАТВИЯ". end.
             when "430" then do: Ret = "ЛИБЕРИЯ". end.
             when "434" then do: Ret = "ЛИВИЯ". end.
             when "438" then do: Ret = "ЛИХТЕНШТЕЙН". end.
             when "440" then do: Ret = "ЛИТВА". end.
             when "442" then do: Ret = "ЛЮКСЕМБУРГ". end.
             when "450" then do: Ret = "МАДАГАСКАР". end.
             when "454" then do: Ret = "МАЛАВИ". end.
             when "458" then do: Ret = "МАЛАЙЗИЯ". end.
             when "462" then do: Ret = "МАЛЬДИВСКИЕ ОСТРОВА". end.
             when "466" then do: Ret = "МАЛИ". end.
             when "470" then do: Ret = "МАЛЬТА". end.
             when "478" then do: Ret = "МАВРИТАНИЯ". end.
             when "480" then do: Ret = "МАВРИКИЙ". end.
             when "484" then do: Ret = "МЕКСИКА". end.
             when "492" then do: Ret = "МОНАКО". end.
             when "496" then do: Ret = "МОНГОЛИЯ". end.
             when "498" then do: Ret = "МОЛДОВА". end.
             when "499" then do: Ret = "ЧЕРНОГОРИЯ". end.
             when "504" then do: Ret = "МАРОККО". end.
             when "508" then do: Ret = "МОЗАМБИК". end.
             when "512" then do: Ret = "ОМАН". end.
             when "516" then do: Ret = "НАМИБИЯ". end.
             when "520" then do: Ret = "НАУРУ". end.
             when "524" then do: Ret = "НЕПАЛ". end.
             when "528" then do: Ret = "НИДЕРЛАНДЫ". end.
             when "533" then do: Ret = "АРУБА". end.
             when "548" then do: Ret = "ВАНУАТУ". end.
             when "554" then do: Ret = "НОВАЯ ЗЕЛАНДИЯ". end.
             when "558" then do: Ret = "НИКАРАГУА". end.
             when "562" then do: Ret = "НИГЕР". end.
             when "566" then do: Ret = "НИГЕРИЯ". end.
             when "578" then do: Ret = "НОРВЕГИЯ". end.
             when "583" then do: Ret = "ФЕДЕРАТИВНЫЕ ШТАТЫ МИКРОНЕЗИИ". end.
             when "584" then do: Ret = "МАРШАЛЛОВЫ ОСТРОВА". end.
             when "585" then do: Ret = "ПАЛАУ". end.
             when "586" then do: Ret = "ПАКИСТАН". end.
             when "591" then do: Ret = "ПАНАМА". end.
             when "598" then do: Ret = "ПАПУА - НОВАЯ ГВИНЕЯ". end.
             when "600" then do: Ret = "ПАРАГВАЙ". end.
             when "604" then do: Ret = "ПЕРУ". end.
             when "608" then do: Ret = "ФИЛИППИНЫ". end.
             when "616" then do: Ret = "ПОЛЬША". end.
             when "620" then do: Ret = "ПОРТУГАЛИЯ". end.
             when "624" then do: Ret = "ГВИНЕЯ -БИСАУ". end.
             when "626" then do: Ret = "ВОСТОЧНЫЙ ТИМОР". end.
             when "630" then do: Ret = "ПУЭРТО-РИКО". end.
             when "634" then do: Ret = "КАТАР". end.
             when "642" then do: Ret = "РУМЫНИЯ". end.
             when "643" then do: Ret = "РОССИЯ". end.
             when "646" then do: Ret = "РУАНДА". end.
             when "659" then do: Ret = "СЕНТ-КИТС И НЕВИС". end.
             when "662" then do: Ret = "СЕНТ-ЛЮСИЯ". end.
             when "670" then do: Ret = "СЕНТ-ВИНСЕНТ И ГРЕНАДИНЫ". end.
             when "674" then do: Ret = "САН-МАРИНО". end.
             when "678" then do: Ret = "САН-ТОМЕ И ПРИНСИПИ". end.
             when "682" then do: Ret = "САУДОВСКАЯ АРАВИЯ". end.
             when "686" then do: Ret = "СЕНЕГАЛ". end.
             when "688" then do: Ret = "СЕРБИЯ". end.
             when "690" then do: Ret = "СЕЙШЕЛЬСКИЕ ОСТРОВА". end.
             when "694" then do: Ret = "СЬЕРРА-ЛЕОНЕ". end.
             when "702" then do: Ret = "СИНГАПУР". end.
             when "703" then do: Ret = "СЛОВАКИЯ". end.
             when "704" then do: Ret = "ВЬЕТНАМ". end.
             when "705" then do: Ret = "СЛОВЕНИЯ". end.
             when "706" then do: Ret = "СОМАЛИ". end.
             when "710" then do: Ret = "ЮАР". end.
             when "716" then do: Ret = "ЗИМБАБВЕ". end.
             when "724" then do: Ret = "ИСПАНИЯ". end.
             when "736" then do: Ret = "СУДАН". end.
             when "740" then do: Ret = "СУРИНАМ". end.
             when "748" then do: Ret = "СВАЗИЛЕНД". end.
             when "752" then do: Ret = "ШВЕЦИЯ". end.
             when "756" then do: Ret = "ШВЕЙЦАРИЯ". end.
             when "760" then do: Ret = "СИРИЯ". end.
             when "762" then do: Ret = "ТАДЖИКИСТАН". end.
             when "764" then do: Ret = "ТАИЛАНД". end.
             when "768" then do: Ret = "ТОГО". end.
             when "776" then do: Ret = "ТОНГА". end.
             when "780" then do: Ret = "ТРИНИДАД И ТОБАГО". end.
             when "784" then do: Ret = "ОАЭ". end.
             when "788" then do: Ret = "ТУНИС". end.
             when "792" then do: Ret = "ТУРЦИЯ". end.
             when "795" then do: Ret = "ТУРКМЕНИСТАН". end.
             when "798" then do: Ret = "ТУВАЛУ". end.
             when "800" then do: Ret = "УГАНДА". end.
             when "804" then do: Ret = "УКРАИНА". end.
             when "807" then do: Ret = "РЕСПУБЛИКА МАКЕДОНИЯ". end.
             when "818" then do: Ret = "ЕГИПЕТ". end.
             when "826" then do: Ret = "ВЕЛИКОБРИТАНИЯ". end.
             when "834" then do: Ret = "ТАНЗАНИЯ". end.
             when "840" then do: Ret = "США". end.
             when "854" then do: Ret = "БУРКИНА-ФАСО". end.
             when "858" then do: Ret = "УРУГВАЙ". end.
             when "860" then do: Ret = "УЗБЕКИСТАН". end.
             when "862" then do: Ret = "ВЕНЕСУЭЛА". end.
             when "882" then do: Ret = "САМОА". end.
             when "887" then do: Ret = "ЙЕМЕН". end.
             when "894" then do: Ret = "ЗАМБИЯ". end.
             when "895" then do: Ret = "АБХАЗИЯ". end.
             when "896" then do: Ret = "ЮЖНАЯ ОСЕТИЯ". end.
            otherwise do: Ret = 'НЕИЗВЕСТНАЯ СТРАНА ' + Val. end.
        end case.
        return Ret.
    END METHOD.
    /*************************************************************************************************************/
    METHOD PUBLIC CHAR CodeToAlpha(INPUT Val AS CHAR):
     def var Ret as char.
        case Val:
            when "004" then do: Ret = "AFG". end.
             when "008" then do: Ret = "ALB". end.
             when "012" then do: Ret = "DZA". end.
             when "020" then do: Ret = "AND". end.
             when "024" then do: Ret = "AGO". end.
             when "028" then do: Ret = "ATG". end.
             when "031" then do: Ret = "AZE". end.
             when "032" then do: Ret = "ARG". end.
             when "036" then do: Ret = "AUS". end.
             when "040" then do: Ret = "AUT". end.
             when "044" then do: Ret = "BHS". end.
             when "048" then do: Ret = "BHR". end.
             when "050" then do: Ret = "BGD". end.
             when "051" then do: Ret = "ARM". end.
             when "052" then do: Ret = "BRB". end.
             when "056" then do: Ret = "BEL". end.
             when "064" then do: Ret = "BTN". end.
             when "068" then do: Ret = "BOL". end.
             when "070" then do: Ret = "BIH". end.
             when "072" then do: Ret = "BWA". end.
             when "076" then do: Ret = "BRA". end.
             when "084" then do: Ret = "BLZ". end.
             when "090" then do: Ret = "SLB". end.
             when "096" then do: Ret = "BRN". end.
             when "100" then do: Ret = "BGR". end.
             when "104" then do: Ret = "MMR". end.
             when "108" then do: Ret = "BDI". end.
             when "112" then do: Ret = "BLR". end.
             when "116" then do: Ret = "KHM". end.
             when "120" then do: Ret = "CMR". end.
             when "124" then do: Ret = "CAN". end.
             when "132" then do: Ret = "CPV". end.
             when "136" then do: Ret = "CYM". end.
             when "140" then do: Ret = "CAF". end.
             when "144" then do: Ret = "LKA". end.
             when "148" then do: Ret = "TCD". end.
             when "152" then do: Ret = "CHL". end.
             when "156" then do: Ret = "CHN". end.
             when "170" then do: Ret = "COL". end.
             when "174" then do: Ret = "COM". end.
             when "178" then do: Ret = "COG". end.
             when "180" then do: Ret = "COD". end.
             when "184" then do: Ret = "COK". end.
             when "188" then do: Ret = "CRI". end.
             when "191" then do: Ret = "HRV". end.
             when "192" then do: Ret = "CUB". end.
             when "196" then do: Ret = "CYP". end.
             when "203" then do: Ret = "CZE". end.
             when "204" then do: Ret = "BEN". end.
             when "208" then do: Ret = "DNK". end.
             when "214" then do: Ret = "DOM". end.
             when "218" then do: Ret = "ECU". end.
             when "222" then do: Ret = "SLV". end.
             when "226" then do: Ret = "GNQ". end.
             when "231" then do: Ret = "ETH". end.
             when "232" then do: Ret = "ERI". end.
             when "233" then do: Ret = "EST". end.
             when "242" then do: Ret = "FJI". end.
             when "246" then do: Ret = "FIN". end.
             when "250" then do: Ret = "FRA". end.
             when "262" then do: Ret = "DJI". end.
             when "266" then do: Ret = "GAB". end.
             when "268" then do: Ret = "GEO". end.
             when "270" then do: Ret = "GMB". end.
             when "275" then do: Ret = "PSE". end.
             when "276" then do: Ret = "DEU". end.
             when "288" then do: Ret = "GHA". end.
             when "296" then do: Ret = "KIR". end.
             when "300" then do: Ret = "GRC". end.
             when "308" then do: Ret = "GRD". end.
             when "320" then do: Ret = "GTM". end.
             when "324" then do: Ret = "GIN". end.
             when "328" then do: Ret = "GUY". end.
             when "332" then do: Ret = "HTI". end.
             when "336" then do: Ret = "VAT". end.
             when "340" then do: Ret = "HND". end.
             when "344" then do: Ret = "HKG". end.
             when "348" then do: Ret = "HUN". end.
             when "352" then do: Ret = "ISL". end.
             when "356" then do: Ret = "IND". end.
             when "360" then do: Ret = "IDN". end.
             when "364" then do: Ret = "IRN". end.
             when "368" then do: Ret = "IRQ". end.
             when "372" then do: Ret = "IRL". end.
             when "376" then do: Ret = "ISR". end.
             when "380" then do: Ret = "ITA". end.
             when "384" then do: Ret = "CIV". end.
             when "388" then do: Ret = "JAM". end.
             when "392" then do: Ret = "JPN". end.
             when "398" then do: Ret = "KAZ". end.
             when "400" then do: Ret = "JOR". end.
             when "404" then do: Ret = "KEN". end.
             when "408" then do: Ret = "PRK". end.
             when "410" then do: Ret = "KOR". end.
             when "414" then do: Ret = "KWT". end.
             when "417" then do: Ret = "KGZ". end.
             when "418" then do: Ret = "LAO". end.
             when "422" then do: Ret = "LBN". end.
             when "426" then do: Ret = "LSO". end.
             when "428" then do: Ret = "LVA". end.
             when "430" then do: Ret = "LBR". end.
             when "434" then do: Ret = "LBY". end.
             when "438" then do: Ret = "LIE". end.
             when "440" then do: Ret = "LTU". end.
             when "442" then do: Ret = "LUX". end.
             when "450" then do: Ret = "MDG". end.
             when "454" then do: Ret = "MWI". end.
             when "458" then do: Ret = "MYS". end.
             when "462" then do: Ret = "MDV". end.
             when "466" then do: Ret = "MLI". end.
             when "470" then do: Ret = "MLT". end.
             when "478" then do: Ret = "MRT". end.
             when "480" then do: Ret = "MUS". end.
             when "484" then do: Ret = "MEX". end.
             when "492" then do: Ret = "MCO". end.
             when "496" then do: Ret = "MNG". end.
             when "498" then do: Ret = "MDA". end.
             when "499" then do: Ret = "MNE". end.
             when "504" then do: Ret = "MAR". end.
             when "508" then do: Ret = "MOZ". end.
             when "512" then do: Ret = "OMN". end.
             when "516" then do: Ret = "NAM". end.
             when "520" then do: Ret = "NR ". end.
             when "524" then do: Ret = "NPL". end.
             when "528" then do: Ret = "NLD". end.
             when "533" then do: Ret = "ABW". end.
             when "548" then do: Ret = "VUT". end.
             when "554" then do: Ret = "NZL". end.
             when "558" then do: Ret = "NIC". end.
             when "562" then do: Ret = "NER". end.
             when "566" then do: Ret = "NGA". end.
             when "578" then do: Ret = "NOR". end.
             when "583" then do: Ret = "FSM". end.
             when "584" then do: Ret = "MHL". end.
             when "585" then do: Ret = "PLW". end.
             when "586" then do: Ret = "PAK". end.
             when "591" then do: Ret = "PAN". end.
             when "598" then do: Ret = "PNG". end.
             when "600" then do: Ret = "PRY". end.
             when "604" then do: Ret = "PER". end.
             when "608" then do: Ret = "PHL". end.
             when "616" then do: Ret = "POL". end.
             when "620" then do: Ret = "PRT". end.
             when "624" then do: Ret = "GNB". end.
             when "626" then do: Ret = "TLS". end.
             when "630" then do: Ret = "PRI". end.
             when "634" then do: Ret = "QAT". end.
             when "642" then do: Ret = "ROU". end.
             when "643" then do: Ret = "RUS". end.
             when "646" then do: Ret = "RWA". end.
             when "659" then do: Ret = "KNA". end.
             when "662" then do: Ret = "LCA". end.
             when "670" then do: Ret = "VCT". end.
             when "674" then do: Ret = "SMR". end.
             when "678" then do: Ret = "STP". end.
             when "682" then do: Ret = "SAU". end.
             when "686" then do: Ret = "SEN". end.
             when "688" then do: Ret = "SCG". end.
             when "690" then do: Ret = "SYC". end.
             when "694" then do: Ret = "SLE". end.
             when "702" then do: Ret = "SGP". end.
             when "703" then do: Ret = "SVK". end.
             when "704" then do: Ret = "VNM". end.
             when "705" then do: Ret = "SVN". end.
             when "706" then do: Ret = "SOM". end.
             when "710" then do: Ret = "ZAF". end.
             when "716" then do: Ret = "ZWE". end.
             when "724" then do: Ret = "ESP". end.
             when "736" then do: Ret = "SDN". end.
             when "740" then do: Ret = "SUR". end.
             when "748" then do: Ret = "SWZ". end.
             when "752" then do: Ret = "SWE". end.
             when "756" then do: Ret = "CHE". end.
             when "760" then do: Ret = "SYR". end.
             when "762" then do: Ret = "TJK". end.
             when "764" then do: Ret = "THA". end.
             when "768" then do: Ret = "TGO". end.
             when "776" then do: Ret = "TON". end.
             when "780" then do: Ret = "TTO". end.
             when "784" then do: Ret = "ARE". end.
             when "788" then do: Ret = "TUN". end.
             when "792" then do: Ret = "TUR". end.
             when "795" then do: Ret = "TKM". end.
             when "798" then do: Ret = "TUV". end.
             when "800" then do: Ret = "UGA". end.
             when "804" then do: Ret = "UKR". end.
             when "807" then do: Ret = "MKD". end.
             when "818" then do: Ret = "EGY". end.
             when "826" then do: Ret = "GBR". end.
             when "834" then do: Ret = "TZA". end.
             when "840" then do: Ret = "USA". end.
             when "854" then do: Ret = "BFA". end.
             when "858" then do: Ret = "URY". end.
             when "860" then do: Ret = "UZB". end.
             when "862" then do: Ret = "VEN". end.
             when "882" then do: Ret = "WSM". end.
             when "887" then do: Ret = "YEM". end.
             when "894" then do: Ret = "ZMB". end.
             when "895" then do: Ret = "ABH". end.
             when "896" then do: Ret = "OST". end.
            otherwise do: Ret = 'НЕИЗВЕСТНАЯ СТРАНА ' + Val. end.
        end case.
        return Ret.
    END METHOD.
    /*************************************************************************************************************/
    METHOD PUBLIC CHAR IdToAlpha(INPUT Val AS CHAR):
     def var Ret as char.
        case Val:
             when "1" then do: Ret = "AZE". end.
             when "2" then do: Ret = "ARM". end.
             when "3" then do: Ret = "BLR". end.
             when "4" then do: Ret = "BEL". end.
             when "5" then do: Ret = "BGR". end.
             when "6" then do: Ret = "GBR". end.
             when "7" then do: Ret = "GEO". end.
             when "8" then do: Ret = "KAZ". end.
             when "9" then do: Ret = "KGZ". end.
             when "10" then do: Ret = "CHN". end.
             when "12" then do: Ret = "LVA". end.
             when "13" then do: Ret = "LTU". end.
             when "15" then do: Ret = "MDA". end.
             when "17" then do: Ret = "NLD". end.
             when "18" then do: Ret = "RUS". end.
             when "19" then do: Ret = "ROU". end.
             when "20" then do: Ret = "TJK". end.
             when "21" then do: Ret = "TUR". end.
             when "22" then do: Ret = "UZB". end.
             when "23" then do: Ret = "UKR". end.
             when "24" then do: Ret = "CZE". end.
             when "25" then do: Ret = "MNG". end.
             when "26" then do: Ret = "USA". end.
             when "27" then do: Ret = "ARE". end.
             when "28" then do: Ret = "ETH". end.
             when "29" then do: Ret = "KEN". end.
             when "30" then do: Ret = "SDN". end.
             when "31" then do: Ret = "CAN". end.
             when "32" then do: Ret = "ARG". end.
             when "33" then do: Ret = "ESP". end.
             when "34" then do: Ret = "PHL". end.
             when "35" then do: Ret = "ABW". end.
             when "36" then do: Ret = "AUS". end.
             when "37" then do: Ret = "BOL". end.
             when "38" then do: Ret = "CYM". end.
             when "39" then do: Ret = "CHL". end.
             when "40" then do: Ret = "COL". end.
             when "41" then do: Ret = "ECU". end.
             when "42" then do: Ret = "DEU". end.
             when "43" then do: Ret = "NZL". end.
             when "44" then do: Ret = "PER". end.
             when "45" then do: Ret = "PRT". end.
             when "46" then do: Ret = "CHE". end.
             when "47" then do: Ret = "KOR". end.
             when "48" then do: Ret = "VNM". end.
             when "49" then do: Ret = "POL". end.
             when "50" then do: Ret = "DNK". end.
             when "51" then do: Ret = "EST". end.
             when "52" then do: Ret = "TKM". end.
             when "53" then do: Ret = "ISR". end.
             when "54" then do: Ret = "CYP". end.
             when "55" then do: Ret = "GRC". end.
             when "56" then do: Ret = "FRA". end.
             when "57" then do: Ret = "ITA". end.
             when "58" then do: Ret = "PRI". end.
             when "59" then do: Ret = "EGY". end.
             when "60" then do: Ret = "BEN". end.
             when "62" then do: Ret = "CMR". end.
             when "63" then do: Ret = "CRI". end.
             when "64" then do: Ret = "CUB". end.
             when "65" then do: Ret = "COG". end.
             when "66" then do: Ret = "SLV". end.
             when "67" then do: Ret = "GHA". end.
             when "68" then do: Ret = "GTM". end.
             when "69" then do: Ret = "MAR". end.
             when "70" then do: Ret = "NIC". end.
             when "71" then do: Ret = "NER". end.
             when "72" then do: Ret = "PAN". end.
             when "73" then do: Ret = "SEN". end.
             when "74" then do: Ret = "SUR". end.
             when "75" then do: Ret = "TGO". end.
             when "76" then do: Ret = "VEN". end.
             when "77" then do: Ret = "IND". end.
             when "80" then do: Ret = "IDN". end.
             when "81" then do: Ret = "BIH". end.
             when "82" then do: Ret = "BDI". end.
             when "83" then do: Ret = "IRN". end.
             when "84" then do: Ret = "LBN". end.
             when "85" then do: Ret = "MNE". end.
             when "86" then do: Ret = "SWE". end.
             when "87" then do: Ret = "SCG". end.
             when "88" then do: Ret = "BRA". end.
             when "89" then do: Ret = "CPV". end.
             when "90" then do: Ret = "MLI". end.
             when "91" then do: Ret = "MRT". end.
             when "92" then do: Ret = "MEX". end.
             when "93" then do: Ret = "ATG". end.
             when "94" then do: Ret = "AFG". end.
             when "95" then do: Ret = "BFA". end.
             when "97" then do: Ret = "CIV". end.
             when "98" then do: Ret = "COD". end.
             when "99" then do: Ret = "DOM". end.
             when "100" then do: Ret = "GIN". end.
             when "101" then do: Ret = "HND". end.
             when "102" then do: Ret = "NGA". end.
             when "103" then do: Ret = "PAK". end.
             when "104" then do: Ret = "PRY". end.
             when "105" then do: Ret = "RWA". end.
             when "106" then do: Ret = "SLE". end.
             when "107" then do: Ret = "ALB". end.
             when "108" then do: Ret = "BRB". end.
             when "109" then do: Ret = "FJI". end.
             when "110" then do: Ret = "GMB". end.
             when "111" then do: Ret = "GUY". end.
             when "112" then do: Ret = "JAM". end.
             when "113" then do: Ret = "NPL". end.
             when "114" then do: Ret = "TUN". end.
             when "115" then do: Ret = "TON". end.
             when "116" then do: Ret = "TTO". end.
             when "117" then do: Ret = "URY". end.
             when "118" then do: Ret = "WSM". end.
             when "119" then do: Ret = "BGD". end.
             when "120" then do: Ret = "COK". end.
             when "121" then do: Ret = "HTI". end.
             when "123" then do: Ret = "DZA". end.
             when "124" then do: Ret = "BHR". end.
             when "125" then do: Ret = "BWA". end.
             when "126" then do: Ret = "ERI". end.
             when "127" then do: Ret = "HKG". end.
             when "128" then do: Ret = "JOR". end.
             when "129" then do: Ret = "KWT". end.
             when "130" then do: Ret = "QAT". end.
             when "131" then do: Ret = "SAU". end.
             when "132" then do: Ret = "LKA". end.
             when "133" then do: Ret = "SYR". end.
             when "134" then do: Ret = "YEM". end.
             when "135" then do: Ret = "THA". end.
             when "136" then do: Ret = "MYS". end.
             when "137" then do: Ret = "SGP". end.
             when "138" then do: Ret = "MDV". end.
             when "139" then do: Ret = "OMN". end.
             when "142" then do: Ret = "FIN". end.
             when "143" then do: Ret = "AGO". end.
             when "144" then do: Ret = "SVK". end.
             when "148" then do: Ret = "HRV". end.
             when "149" then do: Ret = "NAM". end.
             when "150" then do: Ret = "TZA". end.
             when "151" then do: Ret = "ABH". end.
             when "152" then do: Ret = "OST". end.
             when "153" then do: Ret = "IRL". end.
             when "154" then do: Ret = "LAO". end.
             when "155" then do: Ret = "KHM". end.
             when "156" then do: Ret = "IRQ". end.
             when "157" then do: Ret = "PSE". end.
             when "158" then do: Ret = "ZWE". end.
             when "159" then do: Ret = "GNB". end.
             when "160" then do: Ret = "HUN". end.
             when "161" then do: Ret = "AUT". end.
             when "162" then do: Ret = "AND". end.
             when "163" then do: Ret = "BHS". end.
             when "164" then do: Ret = "BLZ". end.
             when "165" then do: Ret = "BRN". end.
             when "166" then do: Ret = "BTN". end.
             when "167" then do: Ret = "VUT". end.
             when "168" then do: Ret = "TLS". end.
             when "169" then do: Ret = "GAB". end.
             when "170" then do: Ret = "GRD". end.
             when "171" then do: Ret = "DJI". end.
             when "172" then do: Ret = "VAT". end.
             when "173" then do: Ret = "ZMB". end.
             when "174" then do: Ret = "ISL". end.
             when "179" then do: Ret = "KIR". end.
             when "180" then do: Ret = "PRK". end.
             when "181" then do: Ret = "COM". end.
             when "182" then do: Ret = "LSO". end.
             when "183" then do: Ret = "LBR". end.
             when "184" then do: Ret = "LBY". end.
             when "185" then do: Ret = "LIE". end.
             when "186" then do: Ret = "LUX". end.
             when "187" then do: Ret = "MUS". end.
             when "188" then do: Ret = "MDG". end.
             when "189" then do: Ret = "MWI". end.
             when "190" then do: Ret = "MLT". end.
             when "191" then do: Ret = "MHL". end.
             when "192" then do: Ret = "MOZ". end.
             when "193" then do: Ret = "MCO". end.
             when "194" then do: Ret = "MMR". end.
             when "195" then do: Ret = "NR ". end.
             when "196" then do: Ret = "NOR". end.
             when "197" then do: Ret = "PLW". end.
             when "198" then do: Ret = "PNG". end.
             when "200" then do: Ret = "SMR". end.
             when "201" then do: Ret = "STP". end.
             when "202" then do: Ret = "SWZ". end.
             when "203" then do: Ret = "SYC". end.
             when "204" then do: Ret = "VCT". end.
             when "205" then do: Ret = "KNA". end.
             when "206" then do: Ret = "LCA". end.
             when "207" then do: Ret = "SVN". end.
             when "208" then do: Ret = "SLB". end.
             when "209" then do: Ret = "SOM". end.
             when "210" then do: Ret = "TUV". end.
             when "211" then do: Ret = "UGA". end.
             when "212" then do: Ret = "FSM". end.
             when "213" then do: Ret = "CAF". end.
             when "214" then do: Ret = "TCD". end.
             when "215" then do: Ret = "ZAF". end.
             when "216" then do: Ret = "JPN". end.
             when "217" then do: Ret = "MKD". end.
             when "218" then do: Ret = "GNQ". end.
            otherwise do: Ret = 'НЕИЗВЕСТНАЯ СТРАНА ' + Val. end.
        end case.
        return Ret.
    END METHOD.
    /*************************************************************************************************************/


END CLASS.











