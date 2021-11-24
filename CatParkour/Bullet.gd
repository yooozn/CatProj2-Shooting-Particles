extends RigidBody

var speed = 2
var shoot = false
func _physics_process(delta):
	if shoot == false:
		apply_impulse(transform.basis.z, -transform.basis.z / 50)
		shoot = true

func _on_Bullet_body_entered(body):
	if body.is_in_group("Enemies"):
		queue_free()
	else:
		print("die")
		queue_free()
