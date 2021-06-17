{
	product => "Patches",
	component => "Unkown",
	version => "unspecified",
	summary => 'Revert "irqbypass: do not start cons/prod when failed connect"',
	description => 'https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/?id=51484429c6108154aba25b97b2e83097a6487e35

commit 51484429c6108154aba25b97b2e83097a6487e35
Author: Zhu Lingshan <lingshan.zhu@intel.com>
Date:   Sat May 8 15:11:52 2021 +0800

    Revert "irqbypass: do not start cons/prod when failed connect"
    
    commit e44b49f623c77bee7451f1a82ccfb969c1028ae2 upstream.
    
    This reverts commit a979a6aa009f3c99689432e0cdb5402a4463fb88.
    
    The reverted commit may cause VM freeze on arm64 with GICv4,
    where stopping a consumer is implemented by suspending the VM.
    Should the connect fail, the VM will not be resumed, which
    is a bit of a problem.
    
    It also erroneously calls the producer destructor unconditionally,
    which is unexpected.
    
    Reported-by: Shaokun Zhang <zhangshaokun@hisilicon.com>
    Suggested-by: Marc Zyngier <maz@kernel.org>
    Acked-by: Jason Wang <jasowang@redhat.com>
    Acked-by: Michael S. Tsirkin <mst@redhat.com>
    Reviewed-by: Eric Auger <eric.auger@redhat.com>
    Tested-by: Shaokun Zhang <zhangshaokun@hisilicon.com>
    Signed-off-by: Zhu Lingshan <lingshan.zhu@intel.com>
    [maz: tags and cc-stable, commit message update]
    Signed-off-by: Marc Zyngier <maz@kernel.org>
    Fixes: a979a6aa009f ("irqbypass: do not start cons/prod when failed connect")
    Link: https://lore.kernel.org/r/3a2c66d6-6ca0-8478-d24b-61e8e3241b20@hisilicon.com
    Link: https://lore.kernel.org/r/20210508071152.722425-1-lingshan.zhu@intel.com
    Cc: stable@vger.kernel.org
    Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

 virt/lib/irqbypass.c | 16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)
',

	cf_upstream_commit => "51484429c6108154aba25b97b2e83097a6487e35",
	status_whiteboard => "",
	};
	