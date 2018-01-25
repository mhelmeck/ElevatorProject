-module(elevatorProject).
-compile(export_all).



% - START - init_system
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
  Draw_Manager_PID = spawn(elevatorProject, draw_manager, []),
  Elevator_Manager_PID = spawn(elevatorProject, elevator_manager, []),
  Current_PID = self(),
  put(raport_manager_PID, Raport_Manager_PID),
  put(draw_manager_PID, Draw_Manager_PID),
  put(elevator_manager_PID, Elevator_Manager_PID),
  put(current_PID, Current_PID),

  Star_Aimed_Floor = trunc(rand:uniform()*Fl_Amount),
  main_loop(25, Fl_Amount, Star_Aimed_Floor, First_Elev_Start_Fl, Second_Elev_Start_Fl).
% - END - init_system



% - START - main_loop
main_loop(0, _, _, _, _) ->
  timer:sleep(2000),
  io:format("");
main_loop(N, Fl_Amount, Fl_Aimed, First_Elev_Fl, Second_Elev_Fl) ->
  timer:sleep(1000),
  get(draw_manager_PID) ! {clear_board},
  get(raport_manager_PID) ! {start, First_Elev_Fl, Second_Elev_Fl},
  get(draw_manager_PID) ! {draw_board, Fl_Amount, Fl_Aimed, First_Elev_Fl, Second_Elev_Fl},

  if
    abs(Fl_Aimed-First_Elev_Fl) =< abs(Fl_Aimed-Second_Elev_Fl) ->
      Elev_To_Move = first;
    true ->
      Elev_To_Move = second
  end,
  New_First_Elev_Fl = handle_first_elev(Elev_To_Move, First_Elev_Fl, Fl_Aimed, Fl_Amount),
  New_Second_Elev_Fl = handle_second_elev(Elev_To_Move, Second_Elev_Fl, Fl_Aimed, Fl_Amount),

  New_Fl_Aimed = handle_aim(Fl_Amount, Fl_Aimed, New_First_Elev_Fl, New_Second_Elev_Fl),

  main_loop(N-1, Fl_Amount, New_Fl_Aimed, New_First_Elev_Fl, New_Second_Elev_Fl).
% - END - main_loop

handle_aim(Fl_Amount, Fl_Aimed, New_First_Elev_Fl, _) when New_First_Elev_Fl == Fl_Aimed ->
  timer:sleep(800),
  trunc(rand:uniform()*Fl_Amount);
handle_aim(Fl_Amount, Fl_Aimed, _, New_Second_Elev_Fl) when New_Second_Elev_Fl == Fl_Aimed ->
  timer:sleep(800),
  trunc(rand:uniform()*Fl_Amount);
handle_aim(_, Fl_Aimed, _, _) -> Fl_Aimed.

handle_first_elev(Elev_To_Move, First_Elev_Fl, Fl_Aimed, Fl_Amount) when Elev_To_Move == first ->
  set_elev_new_pos(Fl_Amount, Fl_Aimed, First_Elev_Fl);
handle_first_elev(Elev_To_Move, First_Elev_Fl, _, _) when Elev_To_Move == second ->
  First_Elev_Fl.

handle_second_elev(Elev_To_Move, Second_Elev_Fl, Fl_Aimed, Fl_Amount) when Elev_To_Move == second ->
  set_elev_new_pos(Fl_Amount, Fl_Aimed, Second_Elev_Fl);
handle_second_elev(Elev_To_Move, Second_Elev_Fl, _, _) when Elev_To_Move == first ->
  Second_Elev_Fl.

set_elev_new_pos(_, Fl_Aimed, Curr_Elev_Fl) when Curr_Elev_Fl == Fl_Aimed ->
  Curr_Elev_Fl;
set_elev_new_pos(Fl_Amount, Fl_Aimed, Curr_Elev_Fl) when Curr_Elev_Fl < Fl_Aimed
                                                 andalso Curr_Elev_Fl < Fl_Amount ->
  Curr_Elev_Fl + 1;
set_elev_new_pos(_, Fl_Aimed, Curr_Elev_Fl) when Curr_Elev_Fl > Fl_Aimed
                                                 andalso Curr_Elev_Fl > 0 ->
  Curr_Elev_Fl - 1.


% - START - elevator_manager
elevator_manager() ->
  receive

    _ ->
      io:format("Received error message in elevator_manager function\n"),
      elevator_manager()
  end.
% - END - elevator_manager



% - START - raport_manager
raport_manager() ->
  receive
    {start, A_Floor_Pos, B_Floor_Pos} ->
      io:format("Starting elevator system simulation.\nElevator A is currently on the ~p floor and\nElevator B is currently on the ~p floor.\n", [A_Floor_Pos, B_Floor_Pos]),
      raport_manager();
    {update_info} ->
      io:format("Nothing to update\n"),
      get(current_PID) ! {test},
      raport_manager();
    _ ->
      io:format("Received error message in raport_manager function\n"),
      raport_manager()
  end.
% - END - raport_manager



% - START - draw_manager
draw_manager() ->
  receive
    {draw_board, Fl_Amount, Fl_Aimed, First_Elev_Fl, Second_Elev_Fl} ->
      io:format("Drawing board:\n"),
      io:format("-------------\n"),
      io:format("Elovator needed on ~p floor\n", [Fl_Aimed]),
      draw_board(Fl_Amount, First_Elev_Fl, Second_Elev_Fl),
      draw_manager();
    {clear_board} ->
      io:format("\e[H\e[J"),
      draw_manager();
    _ ->
      io:format("Received error message in draw_manager function\n"),
      draw_manager()
  end.
% - END - draw_manager



%
draw_board(-1, _, _) ->
  io:format("\n\n");
% |X| |X|
draw_board(Fl_Amount, First_Elev_Fl, Second_Elev_Fl) when First_Elev_Fl == Second_Elev_Fl
                                                    andalso First_Elev_Fl == Fl_Amount ->
  io:format("\n\t~p|  |X|  |X| ", [Fl_Amount]),
  draw_board(Fl_Amount-1, First_Elev_Fl, Second_Elev_Fl);
% |X| | |
draw_board(Fl_Amount, First_Elev_Fl, Second_Elev_Fl) when First_Elev_Fl == Fl_Amount ->
  io:format("\n\t~p|  |X|  | | ", [Fl_Amount]),
  draw_board(Fl_Amount-1, First_Elev_Fl, Second_Elev_Fl);
% | | |X|
draw_board(Fl_Amount, First_Elev_Fl, Second_Elev_Fl) when Second_Elev_Fl == Fl_Amount ->
  io:format("\n\t~p|  | |  |X| ", [Fl_Amount]),
  draw_board(Fl_Amount-1, First_Elev_Fl, Second_Elev_Fl);
% | | | |
draw_board(Fl_Amount, First_Elev_Fl, Second_Elev_Fl) ->
  io:format("\n\t~p|  | |  | | ", [Fl_Amount]),
  draw_board(Fl_Amount-1, First_Elev_Fl, Second_Elev_Fl).




%% - TEST -
% io:format("TEST\n"),
% io:format("~p~n", []),
