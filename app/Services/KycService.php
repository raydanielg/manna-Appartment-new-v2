<?php

namespace App\Services;

use App\Models\KycDocument;
use App\Models\Organization;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class KycService
{
    public function submit(Organization $organization, array $data, array $files): KycDocument
    {
        $paths = [];
        foreach (['id_photo_front', 'id_photo_back', 'selfie_photo', 'ownership_proof'] as $field) {
            if (isset($files[$field])) {
                $paths[$field] = Storage::disk('public')->put('kyc/' . $organization->id, $files[$field]);
            }
        }

        $kyc = KycDocument::updateOrCreate(
            ['organization_id' => $organization->id],
            array_merge(
                ['id_number' => $data['id_number'], 'status' => 'pending'],
                $paths
            )
        );

        $organization->update(['kyc_status' => 'pending']);
        return $kyc;
    }

    public function review(KycDocument $kyc, string $status, ?string $notes): KycDocument
    {
        $kyc->update([
            'status' => $status,
            'review_notes' => $notes,
            'reviewed_by' => Auth::id(),
            'reviewed_at' => now(),
        ]);

        $organization = Organization::find($kyc->organization_id);
        if ($organization) {
            $organization->update(['kyc_status' => $status]);
        }

        return $kyc;
    }
}
