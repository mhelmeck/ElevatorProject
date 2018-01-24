-module(elevatorProject).
-compile(export_all).

% - Fl - is a Floor shortcut
% - Elev - is a Elevator shortcut
init_system(Fl_Amount,
            First_Elev_Start_Fl,
            Second_Elev_Start_Fl) when is_integer(Fl_Amount)
                              andalso is_integer(First_Elev_Start_Fl)
                              andalso is_integer(Second_Elev_Start_Fl)
                              andalso First_Elev_Start_Fl >= 0
                              andalso Second_Elev_Start_Fl >= 0
                              andalso First_Elev_Start_Fl =< Fl_Amount
                              andalso Second_Elev_Start_Fl =< Fl_Amount
                              ->
  Raport_Manager_PID = spawn(elevatorProject, raport_manager, []),
  put(raport_manager_PID, Raport_Manager_PID),

  get(raport_manager_PID) ! {start, First_Elev_Start_Fl, Second_Elev_Start_Fl},
  main_loop().

main_loop() ->
  io:format("TEST\n"),
  timer:sleep(1000),
  main_loop().

%
raport_manager() ->
  receive
    {start, A_Floor_Pos, B_Floor_Pos} ->
      io:format("Starting elevator system simulation.\nElevator A is currently on the ~p floor and\nElevator B is currently on the ~p floor.\n", [A_Floor_Pos, B_Floor_Pos]),
      raport_manager();
    {update_info} ->
      io:format("Nothing to update\n"),
      raport_manager();
    _ ->
      io:format("Received error message in raport_manager function\n"),
      raport_manager()
    end.

% draw_manager() ->
