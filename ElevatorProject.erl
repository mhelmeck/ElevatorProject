-module(elevatorProject).
-compile(export_all).

%%
start(F_Amount, First_F, Last_F) when is_integer(F_Amount)
                                andalso is_integer(First_F)
                                andalso is_integer(Last_F)
                                andalso First_F >= 0
                                andalso First_F < Last_F
                                ->
  Root_PID = spawn(elevatorProject, init_manager, [F_Amount]),
  put(root_PID, Root_PID).


%%
init_manager(F_Amount) ->
  Raport_Manager_PID = spawn(elevatorProject, raport_manager, []),
  Main_Loop_PID = spawn(elevatorProject, main_loop, []),
  put(raport_manager_PID, Raport_Manager_PID),
  put(main_loop_PID, Main_Loop_PID),
  get(raport_manager_PID) ! {start, 0, 0}.


%%
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


%%
main_loop() ->
  io:format("TEST\n").
