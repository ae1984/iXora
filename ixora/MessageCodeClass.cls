/* MessageCodeClass.cls
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
        BANK COMM TXB
 * AUTHOR
        10.07.2013 k.gitalov
 * CHANGES
        
*/


/* Класс - массив АРП счетов для операций по карт счетам */
CLASS MessageCodeClass:

    def private    var      acc_activ  as char    extent 3. /* АРП счета 186012*/
    def private    var      acc_passiv as char    extent 3. /* АРП счета 286012*/
    def private    var      msg_code   as char.        /* MessageCode*/
    define private variable acc_crc    as integer.
    /*************************************************************************************************************/
    CONSTRUCTOR  public MessageCodeClass():
        InitVal().
    END CONSTRUCTOR.
    /*************************************************************************************************************/
    DESTRUCTOR public MessageCodeClass():

    END DESTRUCTOR.
    /*************************************************************************************************************/
    method public void InitVal():
        def buffer b-sysc for txb.sysc.
        find b-sysc where b-sysc.sysc = 'OURBNK' no-lock no-error.
        if avail b-sysc then
        do:

            if b-sysc.chval = 'TXB00' then   /*ЦО*/
            do:
                acc_activ[1]  = "". /**/
                acc_activ[2]  = "". /**/
                acc_activ[3]  = "". /**/
                acc_passiv[1] = "". /**/
                acc_passiv[2] = "". /**/
                acc_passiv[3] = "". /**/
            end.
            if b-sysc.chval = 'TXB01' then   /*Актобе*/
            do:
                acc_activ[1]  = "KZ30470141860A028201". /**/
                acc_activ[2]  = "KZ77470241860A028601". /**/
                acc_activ[3]  = "KZ92470341860A028801". /**/
                acc_passiv[1] = "KZ08470142860A028301". /**/
                acc_passiv[2] = "KZ23470242860A028501". /**/
                acc_passiv[3] = "KZ38470342860A028701". /**/
            end.

            if b-sysc.chval = 'TXB02' then   /*Костанай*/
            do:
                acc_activ[1]  = "KZ56470141860A025502". /**/
                acc_activ[2]  = "KZ54470241860A026202". /**/
                acc_activ[3]  = "KZ05470341860A026002". /**/
                acc_passiv[1] = "KZ34470142860A025602". /**/
                acc_passiv[2] = "KZ97470242860A026102". /**/
                acc_passiv[3] = "KZ48470342860A025902". /**/
            end.

            if b-sysc.chval = 'TXB03' then   /*"Тараз"*/
            do:
                acc_activ[1]  = "KZ78470141860A025203". /**/
                acc_activ[2]  = "KZ60470241860A025803". /**/
                acc_activ[3]  = "KZ11470341860A025603". /**/
                acc_passiv[1] = "KZ56470142860A025303". /**/
                acc_passiv[2] = "KZ06470242860A025703". /**/
                acc_passiv[3] = "KZ54470342860A025503". /**/
            end.

            if b-sysc.chval = 'TXB04' then /*Уральск*/
            do:
                acc_activ[1]  = "KZ51470141860A025204". /**/
                acc_activ[2]  = "KZ49470241860A025904". /**/
                acc_activ[3]  = "KZ97470341860A025704". /**/
                acc_passiv[1] = "KZ29470142860A025304". /**/
                acc_passiv[2] = "KZ92470242860A025804". /**/
                acc_passiv[3] = "KZ43470342860A025604". /**/
            end.

            if b-sysc.chval = 'TXB05' then /*Караганда*/
            do:
                acc_activ[1]  = "KZ21470141860A027005". /**/
                acc_activ[2]  = "KZ50470241860A028505". /**/
                acc_activ[3]  = "KZ98470341860A028305". /**/
                acc_passiv[1] = "KZ96470142860A027105". /**/
                acc_passiv[2] = "KZ93470242860A028405". /**/
                acc_passiv[3] = "KZ44470342860A028205". /**/
            end.

            if b-sysc.chval = 'TXB06' then /*Семей*/
            do:
                acc_activ[1]  = "KZ94470141860A025206". /**/
                acc_activ[2]  = "KZ92470241860A025906". /**/
                acc_activ[3]  = "KZ43470341860A025706". /**/
                acc_passiv[1] = "KZ72470142860A025306". /**/
                acc_passiv[2] = "KZ38470242860A025806". /**/
                acc_passiv[3] = "KZ86470342860A025606". /**/
            end.


            if b-sysc.chval = 'TXB07' then /*Кокшетау*/
            do:
                acc_activ[1]  = "KZ16470141860A026707". /**/
                acc_activ[2]  = "KZ95470241860A027307". /**/
                acc_activ[3]  = "KZ46470341860A027107". /**/
                acc_passiv[1] = "KZ91470142860A026807". /**/
                acc_passiv[2] = "KZ41470242860A027207". /**/
                acc_passiv[3] = "KZ89470342860A027007". /**/
            end.

            if b-sysc.chval = 'TXB08' then /*Астана*/
            do:
                acc_activ[1]  = "KZ67470141860A028408". /**/
                acc_activ[2]  = "KZ65470241860A029108". /**/
                acc_activ[3]  = "KZ16470341860A028908". /**/
                acc_passiv[1] = "KZ45470142860A028508". /**/
                acc_passiv[2] = "KZ11470242860A029008". /**/
                acc_passiv[3] = "KZ59470342860A028808". /**/
            end.


            if b-sysc.chval = 'TXB09' then /*Павлодар*/
            do:
                acc_activ[1]  = "KZ12470141860A025809". /**/
                acc_activ[2]  = "KZ91470241860A026409". /**/
                acc_activ[3]  = "KZ42470341860A026209". /**/
                acc_passiv[1] = "KZ87470142860A025909". /**/
                acc_passiv[2] = "KZ37470242860A026309". /**/
                acc_passiv[3] = "KZ85470342860A026109". /**/
            end.


            if b-sysc.chval = 'TXB10' then /*Петропавловск*/
            do:
                acc_activ[1]  = "KZ17470141860A026010". /**/
                acc_activ[2]  = "KZ96470241860A026610". /**/
                acc_activ[3]  = "KZ47470341860A026410". /**/
                acc_passiv[1] = "KZ92470142860A026110". /**/
                acc_passiv[2] = "KZ42470242860A026510". /**/
                acc_passiv[3] = "KZ90470342860A026310". /**/
            end.


            if b-sysc.chval = 'TXB11' then  /*Атырау*/
            do:
                acc_activ[1]  = "KZ72470141860A025311". /**/
                acc_activ[2]  = "KZ54470241860A025911". /**/
                acc_activ[3]  = "KZ05470341860A025711". /**/
                acc_passiv[1] = "KZ50470142860A025411". /**/
                acc_passiv[2] = "KZ97470242860A025811". /**/
                acc_passiv[3] = "KZ48470342860A025611". /**/
            end.

            if b-sysc.chval = 'TXB12' then  /*Актау*/
            do:
                acc_activ[1]  = "KZ72470141860A028512". /**/
                acc_activ[2]  = "KZ54470241860A029112". /**/
                acc_activ[3]  = "KZ05470341860A028912". /**/
                acc_passiv[1] = "KZ50470142860A028612". /**/
                acc_passiv[2] = "KZ97470242860A029012". /**/
                acc_passiv[3] = "KZ48470342860A028812". /**/
            end.

            if b-sysc.chval = 'TXB13' then  /*Жезказган*/
            do:
                acc_activ[1]  = "KZ18470141860A025313". /**/
                acc_activ[2]  = "KZ97470241860A025913". /**/
                acc_activ[3]  = "KZ48470341860A025713". /**/
                acc_passiv[1] = "KZ93470142860A025413". /**/
                acc_passiv[2] = "KZ43470242860A025813". /**/
                acc_passiv[3] = "KZ91470342860A025613". /**/
            end.

            if b-sysc.chval = 'TXB14' then  /*Усть-Каменогорск*/
            do:
                acc_activ[1]  = "KZ49470141860A029314". /**/
                acc_activ[2]  = "KZ31470241860A029914". /**/
                acc_activ[3]  = "KZ79470341860A029714". /**/
                acc_passiv[1] = "KZ27470142860A029414". /**/
                acc_passiv[2] = "KZ74470242860A029814". /**/
                acc_passiv[3] = "KZ25470342860A029614". /**/
            end.

            if b-sysc.chval = 'TXB15' then  /*Шымкент*/
            do:
                acc_activ[1]  = "KZ22470141860A029315". /**/
                acc_activ[2]  = "KZ04470241860A029915". /**/
                acc_activ[3]  = "KZ52470341860A029715". /**/
                acc_passiv[1] = "KZ97470142860A029415". /**/
                acc_passiv[2] = "KZ47470242860A029815". /**/
                acc_passiv[3] = "KZ95470342860A029615". /**/
            end.

            if b-sysc.chval = 'TXB16' then   /*Алматинский филиал*/
            do:
                acc_activ[1]  = "KZ18470141860A044616". /**/
                acc_activ[2]  = "KZ95470241860A046416". /**/
                acc_activ[3]  = "KZ29470341860A046716". /**/
                acc_passiv[1] = "KZ93470142860A044716". /**/
                acc_passiv[2] = "KZ41470242860A046316". /**/
                acc_passiv[3] = "KZ72470342860A046616". /**/
            end.
        end.
        else 
        do:
            message "Отсутствует переменная OURBNK!" view-as alert-box.
            DELETE OBJECT THIS-OBJECT  NO-ERROR .
        end.
        acc_crc = 1.
    end method.
    /*************************************************************************************************************/

    method public log SetMessageCode(input cur as integer , input Msg as character ):
        if cur < 1 or cur > 3 then 
        do: 
            message "Неверно указана валюта счета!". 
            return no. 
        end.
        else 
        do:
            if acc_activ[cur] = "" or acc_passiv[cur] = "" then do:
              message "Отсутствует счет в данной валюте!".
              return no.
            end.    
            
            msg_code = Msg.
            acc_crc = cur. 
            return yes.
        end.
    end method.
    /*************************************************************************************************************/
    method public char GetAcc():
        /*  */
        case msg_code:
          when "PAYMFIB" then do: /*Для списания с карт счета*/
           return acc_activ[acc_crc].
          end.
          when "PAYMTOIB" then do: /*Для пополнения карт счета*/
           return acc_passiv[acc_crc].
          end.
          otherwise do:
              message "Неизвестный MessageCode!".
              return "".
          end.
        end case.
        return msg_code.
    end method.
/*************************************************************************************************************/

END CLASS.
/*************************************************************************************************************/