extends ProgressBar

@export var max_value_amount: int
@export var min_value_amount: int
@export var health: int
	
func initializeHealthBar(h, max, min):
	health = h
	self.max_value_amount = max
	self.min_value_amount = min
	self.value = h
	
func updateHealthBar(h, max, min):
	health = h
	self.max_value_amount = max
	self.min_value_amount = min
	self.value = h
	
func _process(delta: float) -> void:
	if self.value != self.max_value_amount:
		self.visible = true
		if self.value <= self.min_value_amount:
			self.visible = false
	else:
		self.visible = false
		
	
