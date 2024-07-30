extends ActionLeaf

func tick(actor, _blackboard):
  if actor.completed_your_action:
	 return SUCCESS
  if actor.cant_do_your_action:
	return FAILURE
  actor.do_your_action()
  return RUNNING

