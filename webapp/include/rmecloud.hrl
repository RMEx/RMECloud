%% Inner data structs
-record(date, 
        {
          year, 
          month, 
          day, 
          hour, 
          min, 
          sec
        }
       ).

-record(user, 
        {
          id, 
          nickname, 
          mail, 
          password, 
          twitter=nil, 
          facebook=nil, 
          skype=nil, 
          steam=nil, 
          youtube=nil, 
          url=nil, 
          avatar=nil, 
          last_connection=nil
         }
       ).

