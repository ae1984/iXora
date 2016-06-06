{  
    l = length($0);
  for (i= 1;i <= l; i++){
    if(substr($0,i,2) == "/*"){
    
    }
    if(substr($0,i,1) == "{"){
      while(substr($0,i,2) != "}"){
        print substr($0,i,1);
        i++;
      }
    } 
    printf "\n" ;
  }
} 


