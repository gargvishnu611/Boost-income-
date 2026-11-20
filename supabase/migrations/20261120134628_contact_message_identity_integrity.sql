
drop policy if exists contact_public_insert on public.contact_messages;
create policy contact_public_insert on public.contact_messages for insert to anon
with check(member_id is null and char_length(trim(name)) between 1 and 100 and char_length(trim(email)) between 3 and 254
and char_length(trim(subject)) between 2 and 160 and char_length(trim(message)) between 5 and 5000);
create policy contact_member_insert on public.contact_messages for insert to authenticated
with check((member_id is null or member_id=(select auth.uid()))
and char_length(trim(name)) between 1 and 100 and char_length(trim(email)) between 3 and 254
and char_length(trim(subject)) between 2 and 160 and char_length(trim(message)) between 5 and 5000);
revoke insert on public.contact_messages from anon,authenticated;
grant insert(name,email,subject,message) on public.contact_messages to anon;
grant insert(name,email,subject,message,member_id) on public.contact_messages to authenticated;
