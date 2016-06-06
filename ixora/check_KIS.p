/* check_KIS.p
 * MODULE
        Процессы/Монитор
 * DESCRIPTION
        Проверить запущени ли процесс
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        17.10.2005 tsoy
 * CHANGES
         
*/


def var v-min  as int.
def var v-hour as int.
def var v-time as char.
def var mailaddr as char init  "support@elexnet.kz, dmitry@elexnet.kz". 


find dproc where pid = "KIS" no-lock no-error.


if avail dproc then do:

     v-time = string(time - l_time, "HH:MM:SS")     .
     v-min  = integer ( substring (v-time, 4,2 )).
     v-hour =  integer ( substring (v-time, 1,2 )).

     if v-hour * 60 + v-min  > 30 then do:

             run mail  ( mailaddr, 
                         "TEXAKABANK <abpk@elexnet.kz>", 
                         "Error : Процесс KIS простаивает более 30 минут !", 
                         "Error : Процесс KIS простаивает более 30 минут !" + "\n",
                         "1", 
                         "", 
                         ""
                       ).
     end.

end.


