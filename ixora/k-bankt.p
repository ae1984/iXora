/* k-bankt.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Справочник банков - настройка корсчетов и времени
 * RUN
        
 * CALLER
        k-bankl.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-10-1, 5-1,S-5
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        19.11.2003 nadejda  - прописала кто добавил запись bankt.who
        02.06.2004 nadejda - изменен смысл поля bankt.aut - теперь это признак, что корсчет открыт именно в этом банке, а не просто через него отправлять
*/

{global.i}
def var v-ans as logi.
def  shared var v-cbankl like bankt.cbank.
def new shared var v-subl like bankt.subl init "DFB".
def new shared var v-time as char init "".
def new shared frame bankt.
def buffer bbankt for bankt.
def var ok as log init no.

{sbrw.i
&start = " "
&head = "bankt"
&headkey = "cbank"
&where = "bankt.cbank = v-cbankl "
&index = "cbank"
&formname = "bankt"
&framename = "bankt"
&addcon = "true"
&deletecon = "true"
&predisplay = "v-subl = bankt.subl.
               v-time =  substr( string(bankt.vtime,'hh:mm:ss'),1,2) +
                         substr( string(bankt.vtime,'hh:mm:ss'),4,2) +
                         substr( string(bankt.vtime,'hh:mm:ss'),7,2).
              "
&display = "bankt.cbank v-subl bankt.acc bankt.crc bankt.aut bankt.racc
            bankt.vdate v-time "
&highlight = "bankt.cbank"
&postcreate = " "
&postdisplay = " "
&postadd = " bankt.cbank = v-cbankl.
             bankt.subl = v-subl.
             bankt.who = g-ofc.  /* 19.11.2003 nadejda */
             bankt.aut = no. /* по умолчанию - банк не собственник корсчета, пусть сознательно подтверждают */
             disp bankt.cbank with frame bankt.
            "

&postkey = "/*
            else if keyfunction(lastkey) = 'RETURN' then do :
            bankt.subl = v-subl. */ "

&postupdate = " 
            v-subl = bankt.subl . 
            update  v-subl help '  DFB   CIF '
            validate ( caps(trim(v-subl)) = 'DFB' or caps(trim(v-subl)) = 'CIF'
            , ' Ошибка !   ' )
            with frame bankt.
            bankt.subl = caps(v-subl).
            repeat on error undo, retry :
            update bankt.acc with frame bankt.
            if v-subl = 'DFB' then do :
              find dfb where dfb.dfb = bankt.acc no-lock no-error.
              if available dfb then do : bankt.crc = dfb.crc. leave. end.
              else do: 
               Message 'Счет не найден   .' . pause. undo, retry.
              end.
            end.
            else do :
              find aaa where aaa.aaa = bankt.acc no-lock no-error.
              if available aaa then do : bankt.crc = aaa.crc. leave. end.
              else do: 
               Message 'Счет не найден   .' . pause. undo, retry.
              end.
            end.
            end.   /* repeat  */
            display bankt.crc with frame bankt.
            v-time =  substr( string(bankt.vtime,'hh:mm:ss'),1,2) +
                      substr( string(bankt.vtime,'hh:mm:ss'),4,2) +
                      substr( string(bankt.vtime,'hh:mm:ss'),7,2).
            update bankt.aut with frame bankt.
     update bankt.racc help '1-активн, 0-неактивный счет ' with frame bankt.
     if bankt.racc = '1' then do :
       for each bbankt where bbankt.cbank = bankt.cbank and    
        bbankt.crc = bankt.crc use-index fsa no-lock :
        if bbankt.racc = '1' and bbankt.acc ne bankt.acc then do :
         Message 'Валюта ' + string(bankt.crc) + 
           ' может использоваться только 1 раз .'.
         bankt.racc = '0'. 
         bell . 
         pause . 
      end.
     end.

    end.
      
     display bankt.racc with frame bankt.
      update bankt.vdate validate (bankt.vdate ne ? , 'Ошибка')
            v-time format '99:99:99' validate (
                                     integer(substr(v-time,1,2)) < 24 and
                                     integer(substr(v-time,3,2)) < 60 and
                                     integer(substr(v-time,5,2)) < 60 ,
                                     ' Try again ' )
            with frame bankt.
            bankt.vtime = integer(substr(v-time,1,2)) * 3600 +
                           integer(substr(v-time,3,2)) * 60 +
                           integer(substr(v-time,5,2)).

            "

&end = " "


}
