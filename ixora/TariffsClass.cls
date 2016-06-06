/* TariffsClass.cls
 * MODULE

 * DESCRIPTION
        Класс тарифов - работа с тарификатором
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список функций класса
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK
 * AUTHOR
        25.12.2008 k.gitalov
 * CHANGES

*/

/*Данные по тарифам клиента*/
CLASS TariffsClass:

  def public  var conv_int     as decimal.             /*  Процент комиссии  */
  def public  var conv_int_min as decimal.             /*  Минимальная сумма  */
  def public  var conv_int_max as decimal.             /*  Максимальная сумма  */
  def public  var conv_int_sum as decimal.             /*  Сумма  */
  def public  var comacc       as char.                /*  Номер счета для зачисления комиссии */
  def private var DOC          as CLASS ConvDocClass.  /*  Указатель на текущий документ для которого ищем комисии*/
  def private var TarCod       as char.                /*  Код в тарификаторе */
 /* def private var AccNo        as char. */               /*  Номер счета для поиска льготного тарифа в тарификаторе*/

  def buffer b-tarifex2 for tarifex2.
  def buffer b-tarifex for tarifex.
  def buffer b-tarif2 for tarif2.
 /*************************************************************************************************************/
 CONSTRUCTOR  public TariffsClass(INPUT RealDoc As CLASS ConvDocClass ):
     DOC = RealDoc.
     conv_int = 0.
     conv_int_min = 0.
     conv_int_max = 0.
     TarCod = "".
    /* AccNo = "".*/
 END CONSTRUCTOR.
 /*************************************************************************************************************/
 CONSTRUCTOR  public TariffsClass():
     conv_int = 0.
     conv_int_min = 0.
     conv_int_max = 0.
     TarCod = "".
    /* AccNo = "".*/
     comacc  = "".
 END CONSTRUCTOR.
 /*************************************************************************************************************/
 DESTRUCTOR  public TariffsClass():

 END DESTRUCTOR.
 /*************************************************************************************************************/
 /* Инициализация кода тарификатора в зависимости от типа документа на конвертацию */
 method private log CheckClient():

        /* Проверка на счет для снятия комиссии необходима для перевода суммы комиссии в валюту счета */
        if DOC:com_accno = "" then do: message "Не выбран счет для снятия коммиссии!" view-as alert-box. return false. end.

        /********************************************************************************************************/
        /* TarCod - код в тарификаторе */
        if DOC:Client:clienttype = "p" then do:
          /*физ лица*/
          if DOC:DocType = 1 or DOC:DocType = 3 then do:
            /*if DOC:crc = 4 then TarCod = "814". else*/ TarCod = "809".
          end.
          if DOC:DocType = 2 or DOC:DocType = 4 then do:
            /*if DOC:crc = 4 then TarCod = "815". else*/ TarCod = "810".
          end.
          if DOC:DocType = 6 then
          do:
             /*кросс конвертация*/
             TarCod = "809".
            /* message "Не указан код тарифа для кросс конвертации в классе TariffsClass" view-as alert-box. */
            /* return false.*/
         end.
        end.
        else do:
         /*юр лица*/
          if DOC:DocType = 1 or DOC:DocType = 3 then TarCod = "804".
          if DOC:DocType = 2 or DOC:DocType = 4 then TarCod = "802".
          if DOC:DocType = 6 then
          do:
             /*кросс конвертация*/
             TarCod = "804".
            /* message "Не указан код тарифа для кросс конвертации в классе TariffsClass" view-as alert-box.
             return false. */
          end.
        end.
        /********************************************************************************************************/
        /* При покупке валюты и кросс конвертации тарифы берутся по счету конечной валюты ,
           при продаже валюты тариф берется на счет продаваемой валюты */
        /* AccNo =  DOC:vclientaccno.*/ /*    DOC:client:clientno.*/
        /********************************************************************************************************/

        return true.

 end method.
 /*************************************************************************************************************/
 /* Поиск тарифов */
 method public log FindTarif():

        if CheckClient() = false then return false.


         find first b-tarifex2 where b-tarifex2.aaa  = DOC:vclientaccno
                                 and b-tarifex2.cif  = DOC:Client:clientno
                                 and b-tarifex2.str5 = TarCod
                                 and b-tarifex2.stat = 'r' no-lock no-error.
          if available b-tarifex2 then do:

             conv_int = b-tarifex2.proc.
             conv_int_sum = b-tarifex2.ost.
             conv_int_min = DOC:CRCC:crc-crc(b-tarifex2.min1, b-tarifex2.crc, DOC:CRCC:get-crc(DOC:com_accno)).
	         conv_int_max = DOC:CRCC:crc-crc(b-tarifex2.max1, b-tarifex2.crc, DOC:CRCC:get-crc(DOC:com_accno)).

	         find first b-tarifex where b-tarifex.str5 = TarCod
    	                            and b-tarifex.cif  = DOC:Client:clientno
        	                        and b-tarifex.stat = 'r'  no-lock no-error.
            	if available b-tarifex then comacc = string(b-tarifex.kont).

          end.
          else do:

	         find first b-tarifex where b-tarifex.str5 = TarCod
    	                            and b-tarifex.cif  = DOC:Client:clientno
        	                        and b-tarifex.stat = 'r'  no-lock no-error.
            	if available b-tarifex then do:
            	   comacc = string(b-tarifex.kont).
            	   conv_int = b-tarifex.proc.
            	   conv_int_sum = b-tarifex.ost.
                   conv_int_min = DOC:CRCC:crc-crc(b-tarifex.min1, b-tarifex.crc, DOC:CRCC:get-crc(DOC:com_accno)).
	               conv_int_max = DOC:CRCC:crc-crc(b-tarifex.max1, b-tarifex.crc, DOC:CRCC:get-crc(DOC:com_accno)).
	            end.
        	    else do:
        	        /* Стандартные тарифы */

                    find first b-tarif2 where b-tarif2.num + b-tarif2.kod = TarCod and b-tarif2.stat = 'r' no-lock no-error.
                    if avail b-tarif2 then do:
                      comacc = string(b-tarif2.kont).
                      conv_int = b-tarif2.proc.
                      conv_int_sum = b-tarif2.ost.
                      conv_int_min = DOC:CRCC:crc-crc(b-tarif2.min1, b-tarif2.crc, DOC:CRCC:get-crc(DOC:com_accno)).
                      conv_int_max = DOC:CRCC:crc-crc(b-tarif2.max1, b-tarif2.crc, DOC:CRCC:get-crc(DOC:com_accno)).
                    end.
                    else do:
                      message "Нет записей в тарификаторе с кодом " + TarCod + " !" view-as alert-box.
                      return false.
                    end.
        	    end.
          end.
          return true.
        /********************************************************************************************************/
 end method.
 /*************************************************************************************************************/
  /* Поиск тарифов */
 method public log FindTarif(input Tar as char):
 /* Стандартные тарифы */
                TarCod = Tar.
        	        def buffer b-tarif2 for tarif2.
                    find first b-tarif2 where b-tarif2.num + b-tarif2.kod = TarCod and b-tarif2.stat = 'r' no-lock no-error.
                    if avail b-tarif2 then do:
                      conv_int = b-tarif2.proc.
                      conv_int_sum = b-tarif2.ost.
                      conv_int_min = DOC:CRCC:crc-crc(b-tarif2.min1, b-tarif2.crc, DOC:CRCC:get-crc(DOC:com_accno)).
                      conv_int_max = DOC:CRCC:crc-crc(b-tarif2.max1, b-tarif2.crc, DOC:CRCC:get-crc(DOC:com_accno)).
                    end.
                    else do:
                      message "Нет записей в тарификаторе с кодом " + TarCod + " !" view-as alert-box.
                      return false.
                    end.
         return true.
 end method.
 /*************************************************************************************************************/

 /* Поиск льготных тарифов с курсом на определенную дату */
 method public log FindTarif(input DT as date):

      if CheckClient() = false then return false.

         def buffer b-tarifex2 for tarifex2.
         find first b-tarifex2 where b-tarifex2.aaa  = DOC:vclientaccno
                                 and b-tarifex2.cif  = DOC:Client:clientno
                                 and b-tarifex2.str5 = TarCod
                                 and b-tarifex2.stat = 'r' no-lock no-error.
          if available b-tarifex2 then do:
             conv_int = b-tarifex2.proc.
             conv_int_min = DOC:CRCC:crc-crc-date(b-tarifex2.min1, b-tarifex2.crc, DOC:CRCC:get-crc(DOC:com_accno), DT).
	         conv_int_max = DOC:CRCC:crc-crc-date(b-tarifex2.max1, b-tarifex2.crc, DOC:CRCC:get-crc(DOC:com_accno), DT).
          end.
          else do:
             def buffer b-tarifex for tarifex.
	         find first b-tarifex where b-tarifex.str5 = TarCod
    	                            and b-tarifex.cif  = DOC:Client:clientno
        	                        and b-tarifex.stat = 'r' share-lock no-error.
            	if available b-tarifex then do:
            	   conv_int = b-tarifex.proc.
                   conv_int_min = DOC:CRCC:crc-crc-date(b-tarifex.min1, b-tarifex.crc, DOC:CRCC:get-crc(DOC:com_accno), DT).
	               conv_int_max = DOC:CRCC:crc-crc-date(b-tarifex.max1, b-tarifex.crc, DOC:CRCC:get-crc(DOC:com_accno), DT).
	            end.
	            else do:
                      message "Нет записей в тарификаторе с кодом " + TarCod + " !" view-as alert-box.
                      return false.
                end.
          end.
         return true.
 end method.
 /*************************************************************************************************************/
END CLASS.