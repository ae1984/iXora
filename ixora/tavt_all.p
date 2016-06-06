/* tavt_all.p

 * MODULE
        
 * DESCRIPTION
        Синхронизация тарификатора по филиалам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова 
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM TXB        
 * AUTHOR
        27.07.2009 k.gitalov
 * CHANGES
        
*/

def input param v-num as char.
def input param v-kod as char.
def input param v-kont as int. /* Счет г-к.*/
def input param v-pakalp as char. /*Название*/
def input param v-ost as deci.  
def input param v-proc as deci.
def input param v-max1 as deci.
def input param v-min1 as deci.
def input param v-nr   as int.
def input param v-nr1  as int.
def input param v-nr2  as int.
def input param gt-ofc  as char.
def input param gt-today as date.
def input param v-crc   as int.


def var F-name as char format "x(40)". /*Название филиала*/
def var ListCod as char init "TXB00,TXB01,TXB02,TXB03,TXB04,TXB05,TXB06,TXB07,TXB08,TXB09,TXB10,TXB11,TXB12,TXB13,TXB14,TXB15,TXB16".
def var ListBank as char format "x(25)" extent 17 init ["ЦО","Актобе","Костанай","Тараз","Уральск","Караганда","Семипалатинск","Кокшетау","Астана","Павлодар",
                                     "Петропавловск","Атырау","Актау","Жезказган","Усть-Каменогорск","Шымкент","Алматинский филиал"].


def buffer b-tarifex for txb.tarifex.
/*-------------------------------------------------------------------------------------------------------------*/  
    find txb.sysc where txb.sysc.sysc = 'OURBNK' no-lock no-error.
    if avail txb.sysc then 
    do:
      if txb.sysc.chval = "TXB00" then 
      do:
        /* message "ЦО не обрабатывается!" view-as alert-box.*/
        message "Обработка ЦО...".
       /* return.*/
      end.
    end.
    else do: message "Нет переменной OURBNK" view-as alert-box. return. end.

    F-name  = ListBank[LOOKUP(txb.sysc.chval,ListCod)] NO-ERROR.
    
          
     find last txb.tarif2 where  /* txb.tarif2.stat = 'r'   and */
                                 txb.tarif2.nr   = v-nr  and 
                                 txb.tarif2.nr1  = v-nr1 and 
                                 txb.tarif2.nr2  = v-nr2 exclusive-lock no-error.
     if avail txb.tarif2 then
     do: 
        /* txb.tarif2.num = v-num.
         txb.tarif2.num = v-kod.
         */
         txb.tarif2.stat = 'r'.
         txb.tarif2.akswho = gt-ofc.
         txb.tarif2.akswhn = gt-today.
         txb.tarif2.awtim  = time.                
         txb.tarif2.kont   = v-kont.
         txb.tarif2.pakalp = v-pakalp.
         txb.tarif2.ost = v-ost.
         txb.tarif2.proc = v-proc.
         txb.tarif2.max1 = v-max1.
         txb.tarif2.min1 = v-min1.
         txb.tarif2.crc = v-crc. 
         /* message "Обновление " F-name " - код тарифа - " String(v-nr) String(v-nr2) " счет г-к. " String(v-kont) view-as alert-box.*/
         message "Обновление тарифа в базе филиала г." F-name.
         pause 1. 
         run tarif2his_update.
         release txb.tarif2.
         
         /*только счет ГК*/
         for each b-tarifex where b-tarifex.str5 = v-num + v-kod and b-tarifex.stat = 'r':
           b-tarifex.kont = v-kont.
           run tarifexhis_update.
         end.
         
     end.
     else do: 
      /* message "В базе филиала г." F-name " нет такого тарифа!" view-as alert-box. return. */
         run CreateTarif2.
         run UpdateTarif2.
         release txb.tarif2.
     end.
 
/*-------------------------------------------------------------------------------------------------------------*/ 
 
 
 /* ---- процедура сохранения истории ---- */
procedure tarif2his_update.
	create txb.tarif2his.
	buffer-copy txb.tarif2 to txb.tarif2his.
end procedure.

procedure tarifexhis_update.
    create txb.tarifexhis.
    buffer-copy b-tarifex to txb.tarifexhis.
end procedure.

    
procedure CreateTarif2.
        create txb.tarif2. 
         txb.tarif2.num = v-num.
         txb.tarif2.kod = v-kod.
         txb.tarif2.stat = 'r'.
         txb.tarif2.who = gt-ofc.
         txb.tarif2.whn = gt-today.
         txb.tarif2.wtim  = time.                
         txb.tarif2.kont   = v-kont.
         txb.tarif2.pakalp = v-pakalp.
         txb.tarif2.ost = v-ost.
         txb.tarif2.proc = v-proc.
         txb.tarif2.max1 = v-max1.
         txb.tarif2.min1 = v-min1.
         txb.tarif2.nr   = integer(txb.tarif2.num).
         txb.tarif2.nr1  = v-nr1.
         txb.tarif2.nr2  = integer(txb.tarif2.kod).
         txb.tarif2.crc = v-crc. 
         txb.tarif2.str5   = trim(txb.tarif2.num) + trim(txb.tarif2.kod).
         txb.tarif2.akswho = ''.
         txb.tarif2.akswhn = ?.
         txb.tarif2.awtim  = 0.
         txb.tarif2.delwho = ''.
         txb.tarif2.delwhn = ?.
         txb.tarif2.dwtim  = 0.
         txb.tarif2.stat   = 'c'.
         run tarif2his_update.
      
         message "Создание тарифа в базе филиала г." F-name.
         pause 1.
end procedure.

procedure UpdateTarif2.
  
  find last txb.tarif2 where     txb.tarif2.nr   = v-nr  and 
                                 txb.tarif2.nr1  = v-nr1 and 
                                 txb.tarif2.nr2  = v-nr2 exclusive-lock no-error.
     if avail txb.tarif2 then
     do: 
         txb.tarif2.stat = 'r'.
         txb.tarif2.akswho = gt-ofc.
         txb.tarif2.akswhn = gt-today.
         txb.tarif2.awtim  = time.                
         txb.tarif2.kont   = v-kont.
         txb.tarif2.pakalp = v-pakalp.
         txb.tarif2.ost = v-ost.
         txb.tarif2.proc = v-proc.
         txb.tarif2.max1 = v-max1.
         txb.tarif2.min1 = v-min1.
         txb.tarif2.crc = v-crc. 
         /* message "Обновление " F-name " - код тарифа - " String(v-nr) String(v-nr2) " счет г-к. " String(v-kont) view-as alert-box.*/
         message "Авторизация тарифа в базе филиала г." F-name.
         pause 1. 
         run tarif2his_update.
      end. 
      else do:
        message "Запись не найдена!".
        pause 1.
      end.  
end procedure.