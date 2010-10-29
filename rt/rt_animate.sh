# Script to create animation from raytracing postcirpts after
#  thay have been converted to gifs and placed in one folder

rm anim.gif
convert -delay 50 -dispose none \
			-size 612x792 \
			-fill White -draw 'rectangle 0,0,100,100' \
		-dispose previous \
			-page /tmp/rt/animate/*.gif \
		-loop 1 /tmp/rt/animate/anim.gif 