//SCHEDULE FUNCS
var schedule_endabled = false;

function schedule_callback()
{
    $("#schedule_switcher").attr("src","nstu_map_traffic.png");
    schedule_endabled = true;
    update_schedule_container(d_floor, level_conatainer, level_y_begin);
}

var day = 1;
var pair = 1;
var odd = 0;
var week_num = 1;

var day_str = ["ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ"];
var pair_srt = ["1 пара", "2 пара", "3 пара", "4 пара", "5 пара", "6 пара", "7 пара"];

function schedule_set_day(d, run)
{
    $("#schedule_drop_down_day").html(day_str[d - 1]);
    day = d;
    if (run && schedule_endabled)
        schdeule_RUN(d_floor.level, day, pair, odd)
};

function schedule_set_pair(d, run)
{
    pair = d;
    $("#schedule_drop_down_pair").html(pair_srt[d - 1]);
    if (run && schedule_endabled)
        schdeule_RUN(d_floor.level, day, pair, odd)
};

function schedule_next_week(){week_num++;schedule_set_odd(week_num,true);}
function schedule_prev_week(){week_num--;schedule_set_odd(week_num,true);}
function schedule_cur_week(){schedule_get_week();}

function schedule_set_odd(num, run)
{
    if (num<1) num=1;    
    if (num>20) num=20;
    
    week_num = num;
    odd = num % 2;
    $("#week_num").html(num);
    if (run && schedule_endabled)
        schdeule_RUN(d_floor.level, day, pair, odd);
};

function schdeule_RUN_TO_RUN()
{
    if (schedule_endabled)
        schdeule_RUN(d_floor.level, day, pair, odd);
}

function schedule_RUN_SWITCHER()
{
    if (schedule_endabled)
        schedule_STOP();
    else
        schdeule_RUN(d_floor.level, day, pair, odd);
}

function schdeule_RUN(floor, day, pair, odd)
{
    get_schedule(floor, day, pair, odd, schedule_callback);
}

function schedule_STOP()
{
    $("#schedule_switcher").attr("src","nstu_map_no_traffic.png");
    schedule_endabled = false;
    remove_schedule_container(level_conatainer);
}
