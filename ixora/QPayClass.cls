/* QPayClass.cls
 * MODULE
        Класс документа перевода Золотой Короны
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
        21/07/2011 k.gitalov
 * BASES
        BANK
 * CHANGES
*/



CLASS QPayClass:
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
    DEF PUBLIC VAR PayAmountCRC AS CHAR.             /*Валюта итоговой суммы*/
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

    /*************************************************************************************************************/
    CONSTRUCTOR  public QPayClass( INPUT Val AS CHAR ):
      v-path = "C:\\TEMP\\ZK\\".
      v-name = "QPay.xml".
      UIN = Val.
      PayerIsResident = 0.
      PayeeIsResident = 0.
    END CONSTRUCTOR.
    /*************************************************************************************************************/
    /*
    DESTRUCTOR public QPayClass():

    END DESTRUCTOR.
    */
    /*************************************************************************************************************/
    METHOD PUBLIC LOG CopyDoc():
      def var InFile as char.
      def var v-result as char.
      def var a as char.
      InFile = v-path + 'iabs' + UIN + '.xml'.

      input through value ("scp Administrator@`askhost`:" + replace(InFile ,"\\","\\\\") + " " + v-name).
      repeat:
        import a.
        v-result = v-result + a.
      end.

      /* Для теста */
      unix silent value ("scp Administrator@`askhost`:" + replace(InFile ,"\\","\\\\") + " /data/reports/qpay/iabs" + UIN + '.xml').
     /*
     input through
      repeat:
        import a.
        v-result = v-result + a.
      end.
*/

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
          when "RKIDENTITY" then do:
           return "01-Удостов. личности гражданина РК".
          end.
          when "RKPASSPORT" then do:
           return "02-Паспорт гражданина РК".
          end.
          when "FORNOTCITIZENRK" then do:
           return "03-Паспорт иностранного госуд-ва".
          end.
          when "FOREIGN" then do:
           return "03-Паспорт иностранного госуд-ва".
          end.
          when "RKRESIDENCE" then do:
           return "04-Вид на жительство иностраца в РК".
          end.
          when "NOTCITIZENRK" then do:
           return "05-Удостов. лица без гражданства".
          end.
          when "PASSPORT" then do:
           return "Паспорт гражданина РФ".
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
END CLASS.











