/* dclscheckacc.p
 * MODULE
        Закрытие опердня
 * DESCRIPTION
        Проверка по счетам на неправильно проставленную дату
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        03.24.2005 dpuchkov
 * CHANGES
*/



  for each lgr where lgr.led = "tda"  no-lock :
      for each aaa where aaa.lgr = lgr.lgr and aaa.lstmdt = ? and aaa.sta <> "C" and aaa.sta <> "E" exclusive-lock:
         if aaa.lstmdt = ? then do:
            aaa.sta = "C".
            run savelog("checkacc", aaa.aaa + "  " + string(aaa.regdt)).
         end.
      end.
  end.


