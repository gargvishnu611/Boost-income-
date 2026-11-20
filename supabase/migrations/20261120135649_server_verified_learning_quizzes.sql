
update public.learning_courses
set content = content || jsonb_build_object(
  'quiz', jsonb_build_array(jsonb_build_object(
    'question','What makes a contribution useful?',
    'options',jsonb_build_array('Only the number of actions','A real problem solved with clear evidence','Posting repeatedly'),
    'answer',1
  ))
)
where title='What counts as a useful contribution?' and not (content ? 'quiz');

update public.learning_courses
set content = content || jsonb_build_object(
  'quiz', jsonb_build_array(jsonb_build_object(
    'question','What should you do before submitting?',
    'options',jsonb_build_array('Ignore the requirements','Read acceptance criteria and attach verifiable proof','Copy another member'),
    'answer',1
  ))
)
where title='How to write a strong task submission?' and not (content ? 'quiz');

update public.learning_courses
set content = content || jsonb_build_object(
  'quiz', jsonb_build_array(jsonb_build_object(
    'question','What makes feedback actionable?',
    'options',jsonb_build_array('A vague opinion','Context, a specific observation and a practical next step','Only a rating'),
    'answer',1
  ))
)
where title='Feedback that teams can actually use' and not (content ? 'quiz');

create or replace function public.complete_learning_course(course_uuid uuid, quiz_answers jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  actor uuid := auth.uid();
  course_row public.learning_courses%rowtype;
  quiz jsonb;
  answer integer;
  expected integer;
  i integer;
  xp_id uuid;
begin
  if actor is null then raise exception 'Sign in is required'; end if;
  select * into course_row from public.learning_courses where id=course_uuid and is_published=true;
  if not found then raise exception 'Published course not found'; end if;
  quiz := course_row.content->'quiz';
  if quiz is null or jsonb_typeof(quiz)<>'array' or jsonb_array_length(quiz)=0 then
    raise exception 'This course does not have a quiz yet';
  end if;
  if jsonb_typeof(quiz_answers)<>'array' or jsonb_array_length(quiz_answers)<>jsonb_array_length(quiz) then
    raise exception 'Answer every quiz question';
  end if;
  for i in 0..jsonb_array_length(quiz)-1 loop
    begin
      answer := (quiz_answers->>i)::integer;
      expected := (quiz->i->>'answer')::integer;
    exception when others then
      raise exception 'Invalid quiz answer format';
    end;
    if answer<>expected then
      return jsonb_build_object('passed',false,'message','Not quite. Review the lesson and try again.');
    end if;
  end loop;

  insert into public.course_progress(member_id,course_id,status,progress_percent,completed_at,updated_at)
  values(actor,course_uuid,'completed',100,now(),now())
  on conflict(member_id,course_id) do update set
    status='completed',progress_percent=100,completed_at=coalesce(public.course_progress.completed_at,now()),updated_at=now();

  insert into public.xp_ledger(member_id,amount,reason,source_type,source_id)
  values(actor,15,'Completed learning course: '||course_row.title,'course_complete',course_uuid)
  on conflict do nothing
  returning id into xp_id;

  return jsonb_build_object('passed',true,'awarded',xp_id is not null,'xp',case when xp_id is not null then 15 else 0 end);
end;
$$;

revoke all on function public.complete_learning_course(uuid,jsonb) from public,anon;
grant execute on function public.complete_learning_course(uuid,jsonb) to authenticated;
